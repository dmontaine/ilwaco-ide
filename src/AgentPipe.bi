'###############################################################################
'#  AgentPipe.bi — Ilwaco IDE                                                   #
'#                                                                             #
'#  Agent MCP pipe server: a Unix-domain-socket server inside ilwaco that      #
'#  lets the ilwaco-mcp sidecar drive the IDE. Ported from Astoria IDE's       #
'#  Win32 named-pipe server (MCP_SERVER_PLAN.md).                              #
'#                                                                             #
'#  Threading contract: the socket worker thread NEVER touches GTK widgets.    #
'#  It parses one request, publishes it in the single in-flight command slot,  #
'#  schedules execution on the GTK main loop via gdk_threads_add_idle, and     #
'#  waits for the UI thread to complete.                                       #
'#                                                                             #
'#  Off by default: nothing listens unless StartAgentPipe is called (gated     #
'#  on AllowAgentControl).                                                     #
'###############################################################################
#pragma once

#include once "JsonLite.bi"

'' Start listening (creates the worker thread). Called after the main window exists.
Declare Sub StartAgentPipe()

'' Stop listening and join the worker thread. Safe to call when not started.
Declare Sub StopAgentPipe()

'' Whether the listener is currently up.
Declare Function AgentPipeActive() As Boolean

'' UI-thread half: executes the pending command slot. Call ONLY from the GTK
'' main loop (scheduled via gdk_threads_add_idle).
Declare Sub AgentPipe_ExecutePendingOnUi()

#include once "AgentPipe.bas"
