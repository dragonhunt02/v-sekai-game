// Copyright 2020-2022, Collabora, Ltd.
// SPDX-License-Identifier: BSL-1.0
/*!
 * @file
 * @brief  A cli program to send scripted instructions to the remote driver.
 * @author
 */

#include "math/m_api.h"
#include "remote/r_interface.h"
#include "util/u_logging.h"
#include "xrt/xrt_defines.h"

#include <chrono>
#include <cstdlib>
#include <iostream>
#include <map>
#include <string>
#include <thread>
#include <variant>
#include <string.h>
#include <sys/wait.h>

static void
do_set(r_remote_connection &rc, r_remote_data &rd, const std::string &command);
static void
do_sleep(r_remote_connection &rc, r_remote_data &rd, const std::string &command);
static void
do_exec(r_remote_connection &rc, r_remote_data &rd, const std::string &command);
static void
do_print_state(r_remote_connection &rc, r_remote_data &rd, const std::string &command);

static const std::map<std::string_view, void (*)(r_remote_connection &, r_remote_data &rd, const std::string &)>
    commands = {
        {"set", &do_set},
        {"sleep", &do_sleep},
        {"exec", &do_exec},
        {"print_state", &do_print_state},
};

using controller_input = std::variant<xrt_vec1 r_remote_controller_data::*,
                                      xrt_vec2 r_remote_controller_data::*,
                                      bool r_remote_controller_data::*,
                                      float r_remote_controller_data::*>;

static const std::map<std::string_view, controller_input> inputs = {
    {"trigger_value", &r_remote_controller_data::trigger_value},
    {"squeeze_value", &r_remote_controller_data::squeeze_value},
    {"squeeze_force", &r_remote_controller_data::squeeze_force},
    {"thumbstick", &r_remote_controller_data::thumbstick},
    {"trackpad_force", &r_remote_controller_data::trackpad_force},
    {"trackpad", &r_remote_controller_data::trackpad},
    {"hand_tracking_active", &r_remote_controller_data::hand_tracking_active},
    {"active", &r_remote_controller_data::active},
    {"system_click", &r_remote_controller_data::system_click},
    {"system_touch", &r_remote_controller_data::system_touch},
    {"a_click", &r_remote_controller_data::a_click},
    {"a_touch", &r_remote_controller_data::a_touch},
    {"b_click", &r_remote_controller_data::b_click},
    {"b_touch", &r_remote_controller_data::b_touch},
    {"trigger_click", &r_remote_controller_data::trigger_click},
    {"trigger_touch", &r_remote_controller_data::trigger_touch},
    {"thumbstick_click", &r_remote_controller_data::thumbstick_click},
    {"thumbstick_touch", &r_remote_controller_data::thumbstick_touch},
    {"trackpad_touch", &r_remote_controller_data::trackpad_touch},
};

static int
print_help(int argc, const char **argv)
{
	std::cerr << "Usage: " << argv[0] << " ADDR PORT" << std::endl;
	;
	return 1;
}

static int
do_connect(r_remote_connection &rc, const char *address, const char *port)
{
	uint16_t port_nr = atoi(port);
	U_LOG_D("Connecting to %s:%d", address, port_nr);

	return r_remote_connection_init(&rc, address, port_nr);
}

static std::pair<std::string, std::string>
parse_command(std::string input)
{
	// Remove comments
	if (std::size_t pos = input.find_first_of('#'); pos != std::string::npos) {
		input = input.substr(0, pos);
	}

	// Remove starting whitespaces
	static const std::string_view whitespace = " \t";

	if (std::size_t pos = input.find_first_not_of(whitespace); pos == std::string_view::npos)
		return {};
	else
		input = input.substr(pos);

	// Remove trailing whitespaces
	if (std::size_t pos = input.find_last_not_of(whitespace); pos != std::string_view::npos)
		input = input.substr(0, pos + 1);

	char command[50];
	int consumed = 0;
	sscanf(input.c_str(), "%49s %n", command, &consumed);

	return {command, input.substr(consumed)};
}

static void
do_set_aux(r_remote_controller_data &ctrl, xrt_vec1 r_remote_controller_data::*field, const std::string &args)
{
	if (sscanf(args.c_str(), "%f", &(ctrl.*field).x) != 1)
		std::cerr << "Expected one float" << std::endl;
}

static void
do_set_aux(r_remote_controller_data &ctrl, xrt_vec2 r_remote_controller_data::*field, const std::string &args)
{
	if (sscanf(args.c_str(), "%f %f", &(ctrl.*field).x, &(ctrl.*field).y) != 2)
		std::cerr << "Expected two floats" << std::endl;
}

static void
do_set_position(xrt_vec3 &field, const std::string &args)
{
	if (sscanf(args.c_str(), "%f %f %f", &field.x, &field.y, &field.z) != 3)
		std::cerr << "Expected three floats" << std::endl;
}

static void
do_set_rotation(xrt_quat &field, const std::string &args)
{
	if (sscanf(args.c_str(), "%f %f %f %f", &field.x, &field.y, &field.z, &field.w) != 4)
		std::cerr << "Expected four floats" << std::endl;

	math_quat_normalize(&field);
}

static void
do_set_direction(xrt_quat &field, const std::string &args)
{
	xrt_vec3 dir;
	if (sscanf(args.c_str(), "%f %f %f", &dir.x, &dir.y, &dir.z) != 3)
		std::cerr << "Expected three floats" << std::endl;

	xrt_vec3 aim{0, 0, -1};
	math_quat_from_vec_a_to_vec_b(&aim, &dir, &field);
}

static void
do_set_aux(r_remote_controller_data &ctrl, float r_remote_controller_data::*field, const std::string &args)
{
	if (sscanf(args.c_str(), "%f", &(ctrl.*field)) != 1)
		std::cerr << "Expected one float" << std::endl;
}

static void
do_set_aux(r_remote_controller_data &ctrl, bool r_remote_controller_data::*field, const std::string &args)
{
	char value[20];

	if (sscanf(args.c_str(), "%19s", value) != 1)
		strcpy(value, "");

	if (not strcmp(value, "true")) {
		std::cerr << "Monado set value true" << std::endl;
		ctrl.*field = true;
	} else if (not strcmp(value, "false")) {
		std::cerr << "Monado set value false" << std::endl;
		ctrl.*field = false;
	} else {
		std::cerr << "Expected one bool" << std::endl;
	}
	
}

static void
do_set(r_remote_connection &rc, r_remote_data &rd, const std::string &args)
{
	char controller[50];
	char setting[50];
	int consumed;

	if (sscanf(args.c_str(), "%49s %49s %n", controller, setting, &consumed) != 2) {
		std::cerr << "Usage: set {left|right|head} SETTING VALUE" << std::endl;
		return;
	}

	std::string args2 = args.substr(consumed);

	if (not strcmp(controller, "left") or not strcmp(controller, "right")) {
		r_remote_controller_data &controller_data = (strcmp(controller, "left") == 0) ? rd.left : rd.right;
		
	        std::cerr << "Monado Print setting" << setting << std::endl;

		if (not strcmp(setting, "position")) {
			do_set_position(controller_data.pose.position, args2);
		} else if (not strcmp(setting, "rotation")) {
			do_set_rotation(controller_data.pose.orientation, args2);
		} else if (not strcmp(setting, "direction")) {
			do_set_direction(controller_data.pose.orientation, args2);
		} else if (auto it = inputs.find(setting); it != inputs.end()) {
			std::visit(
			    [&controller_data, &args2](auto field) { do_set_aux(controller_data, field, args2); },
			    it->second);
		} else {
			// Invalid setting
			std::cerr << "Invalid setting\n";
			std::cerr << "Supported settings for " << controller << " are:\n";
			std::cerr << "   position\n";
			std::cerr << "   rotation\n";
			std::cerr << "   direction\n";
			for (auto [i, j] : inputs)
				std::cerr << "   " << i << "\n";
		}
	} else if (not strcmp(controller, "head")) {
		if (not strcmp(setting, "position")) {
			do_set_position(rd.head.center.position, args2);
		} else if (not strcmp(setting, "rotation")) {
			do_set_rotation(rd.head.center.orientation, args2);
		} else if (not strcmp(setting, "direction")) {
			do_set_direction(rd.head.center.orientation, args2);
		} else {
			// Invalid setting
			std::cerr << "Invalid setting\n";
			std::cerr << "Supported settings for " << controller << " are:\n";
			std::cerr << "   position\n";
			std::cerr << "   rotation\n";
			std::cerr << "   direction\n";
		}
	} else {
		// Invalid controller
		std::cerr << "Invalid controller\n";
		std::cerr << "Supported controllers are:\n";
		std::cerr << "   left\n";
		std::cerr << "   right\n";
		std::cerr << "   head\n";
	}

	r_remote_connection_write_one(&rc, &rd);
}

static void
do_print_state([[maybe_unused]] r_remote_connection &rc, r_remote_data &rd, [[maybe_unused]] const std::string &command)
{
	std::cerr << "Head:\n";
	std::cerr << "   Position: (" << rd.head.center.position.x << ", " << rd.head.center.position.y << ", "
	          << rd.head.center.position.z << ")\n";
	std::cerr << "   Rotation: (" << rd.head.center.orientation.x << ", " << rd.head.center.orientation.y << ", "
	          << rd.head.center.orientation.z << ", " << rd.head.center.orientation.w << ")\n";

	for (auto &controller : {rd.left, rd.right}) {
		if (&controller == &rd.left)
			std::cerr << "Left controller:\n";
		else
			std::cerr << "Right controller:\n";

		std::cout << std::boolalpha;
		std::cerr << "   A button: (" << controller.a_click << ")\n";
		std::cerr << "   B button: (" << controller.b_click << ")\n";
		std::cout << std::noboolalpha;
		std::cerr << "   Position: (" << controller.pose.position.x << ", " << controller.pose.position.y
		          << ", " << controller.pose.position.z << ")\n";
		std::cerr << "   Rotation: (" << controller.pose.orientation.x << ", " << controller.pose.orientation.y
		          << ", " << controller.pose.orientation.z << ", " << controller.pose.orientation.w << ")\n";
	}
}

static void
do_sleep([[maybe_unused]] r_remote_connection &rc, [[maybe_unused]] r_remote_data &rd, const std::string &command)
{
	float seconds;

	if (sscanf(command.c_str(), "%f", &seconds) != 1)
		std::cerr << "Expected one float" << std::endl;
	else
		std::this_thread::sleep_for(std::chrono::duration<float>(seconds));
}

static void
do_exec([[maybe_unused]] r_remote_connection &rc, [[maybe_unused]] r_remote_data &rd, const std::string &command)
{
	if (pid_t pid = fork(); pid == 0) {
		execlp("sh", "sh", "-c", command.c_str(), nullptr);
	} else if (pid > 0) {
		int wstatus = 0;
		waitpid(pid, &wstatus, 0);

		if (WIFSIGNALED(wstatus)) {
			std::cerr << "Received signal " << WTERMSIG(wstatus) << " ( SIG"
			          << sigabbrev_np(WTERMSIG(wstatus)) << ")" << std::endl;
			if (WCOREDUMP(wstatus))
				std::cerr << "Core dumped" << std::endl;
		} else if (WEXITSTATUS(wstatus)) {
			std::cerr << "Returned " << WEXITSTATUS(wstatus) << std::endl;
		}
	} else {
		std::cerr << "Cannot fork: " << strerror(errno) << std::endl;
	}
}

static void
do_invalid_command(std::string_view command)
{
	std::cerr << "Invalid command: " << command << std::endl;
}

int
main(int argc, const char **argv)
{
	if (argc != 3) {
		return print_help(argc, argv);
	}

	r_remote_connection rc{};
	if (do_connect(rc, argv[1], argv[2]) != 0) {
		std::cerr << "Cannot connect to " << argv[1] << ":" << argv[2] << std::endl;
		return 1;
	}

	r_remote_data rd{};
	r_remote_connection_read_one(&rc, &rd);
	r_remote_connection_read_one(&rc, &rd);

	while (!std::cin.eof()) {
		std::string input;
		std::getline(std::cin, input);

		auto [command, args] = parse_command(input);

		if (command.empty())
			continue;


		if (auto it = commands.find(command); it != commands.end()) {
			it->second(rc, rd, args);
		} else {
			do_invalid_command(command);
		}
	}
}
