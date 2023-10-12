// This file is auto-generated by ./bin/rails stimulus:manifest:update
// Run that command whenever you add a new controller or create them with
// ./bin/rails generate stimulus controllerName

import { application } from "./application"

import AutogramController from "./autogram_controller"
application.register("autogram", AutogramController)

import MessageDraftsController from "./message_drafts_controller"
application.register("messageDrafts", MessageDraftsController)

import DebounceController from "./debounce_controller"
application.register("debounce", DebounceController)
