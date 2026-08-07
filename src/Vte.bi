'#########################################################
'#  Vte.bi                                               #
'#  This file is part of Ilwaco IDE                      #
'#########################################################
''
'' Minimal hand-written binding for VTE 2.91 — the GTK terminal widget.
''
'' WHY WE BIND IT BY HAND: FreeBASIC ships no VTE headers, and we need only a
'' handful of entry points. Everything here was exercised by a working probe
'' before being written down (a VteTerminal embedded in a GTK container, running
'' /bin/sh, rendering output and sitting at a live `read` prompt), so these
'' signatures are measured rather than transcribed from documentation.
''
'' WHY AN EMBEDDED TERMINAL AT ALL:
''   * a Flatpak sandbox has no host terminal to shell out to, and a program
''     compiled inside the sandbox may not even run on the host;
''   * spawning xfce4-terminal renders a blank window on at least one supported
''     desktop (Documentation/TechnicalDebt.md), which a beginner cannot tell
''     apart from their own program failing;
''   * it lets the terminal-selection option be removed entirely.
''
'' A real pty is the requirement, not just captured output: beginners' FreeBASIC
'' programs use Input, Color, Locate and Cls, which need a terminal underneath.
'' VTE provides one — that is the whole reason it is preferred to a text pane.
''
'' The link target comes from the shim (`libvte-2.91` in build-linux.sh's LIBS).
'' NOTE: Packaging/gen-gtk-links.sh must also learn about libvte before any of
'' this ships, or packaged builds will fail to link.
''
#pragma once

#include once "gtk/gtk.bi"

#inclib "vte-2.91"

'' VtePtyFlags
Const VTE_PTY_DEFAULT = 0

Extern "C"

	'' Returns a GtkWidget*, so it goes straight into gtk_container_add.
	Declare Function vte_terminal_new() As GtkWidget Ptr

	'' Asynchronous spawn. `argv` is NULL-terminated, as for g_spawn; passing 0
	'' for envv inherits ours. `timeout` of -1 means no timeout. The callback may
	'' be 0 when the caller does not need the child pid.
	Declare Sub vte_terminal_spawn_async( _
		ByVal terminal As Any Ptr, _
		ByVal pty_flags As Long, _
		ByVal working_directory As ZString Ptr, _
		ByVal argv As ZString Ptr Ptr, _
		ByVal envv As ZString Ptr Ptr, _
		ByVal spawn_flags As Long, _
		ByVal child_setup As Any Ptr, _
		ByVal child_setup_data As Any Ptr, _
		ByVal child_setup_data_destroy As Any Ptr, _
		ByVal timeout As Long, _
		ByVal cancellable As Any Ptr, _
		ByVal callback As Any Ptr, _
		ByVal user_data As Any Ptr)

	Declare Sub vte_terminal_set_scrollback_lines(ByVal terminal As Any Ptr, ByVal lines_ As Long)

	'' Write text straight into the view without a child process — for the IDE's
	'' own notices ("Program exited with code 0") in the same pane as the output.
	Declare Sub vte_terminal_feed(ByVal terminal As Any Ptr, ByVal text As ZString Ptr, ByVal length As LongInt)

	Declare Sub vte_terminal_reset(ByVal terminal As Any Ptr, ByVal clear_tabstops As Boolean, ByVal clear_history As Boolean)

End Extern
