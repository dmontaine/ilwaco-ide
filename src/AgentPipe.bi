'#########################################################
'#  AgentPipe.bi                                         #
'#  This file is part of Ilwaco IDE                      #
'#                                                       #
'#  Agent MCP command server (Layer C of the MCP design):#
'#  a local Unix-domain-socket server inside ilwaco that #
'#  lets the ilwaco-mcp sidecar drive the IDE.           #
'#                                                       #
'#  Threading contract: the worker thread NEVER touches  #
'#  GTK widgets. It parses one request, publishes it in  #
'#  the single in-flight command slot, schedules         #
'#  execution on the GTK main loop with g_idle_add, and  #
'#  waits (FB condition variable) for the UI thread to   #
'#  complete the slot. This is the Linux/GTK counterpart #
'#  of Astoria's named-pipe + PostMessage(WM_APP) design.#
'#########################################################
#pragma once

#include once "JsonLite.bi"

'' Start listening (creates the worker thread + Unix socket). Idempotent.
Declare Sub StartAgentPipe()

'' Stop listening and join the worker thread. Safe to call when not started.
Declare Sub StopAgentPipe()

'' Whether the listener is currently up.
Declare Function AgentPipeActive() As Boolean

'' Convert between an AgentPermissionLevel and the name shown in the INI, the Options
'' combo and the status bar. FromName is deliberately forgiving about case and spacing,
'' because Settings/ilwaco.ini is edited by hand; anything unrecognised reads as Off.
Declare Function AgentPermissionName(ByVal level As Integer) As UString
Declare Function AgentPermissionFromName(ByRef nm As UString) As Integer

'' True only while a client is actually connected. Use this, not AgentPipeActive,
'' before raising anything modal on the UI thread: a modal blocks the command slot
'' and the worker waits on it, so a prompt nobody can answer stalls the agent.
Declare Function AgentClientConnected() As Boolean

'' NOTE: the implementation (AgentPipe.bas) is included LATE, at the end of ilwaco.bas,
'' because its command handlers reference IDE symbols (MainNode, TabPanels, txtOutput,
'' ProjectElement, ...) that are only defined once every .bi/.bas has been pulled in.
'' This header carries just the declarations so frmMain_Show/frmMain_Close can call them.
