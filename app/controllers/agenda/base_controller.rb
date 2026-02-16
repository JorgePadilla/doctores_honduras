class Agenda::BaseController < ApplicationController
  include AgendaAuthorization
  include SubscriptionGating

  before_action :require_authentication
  before_action :require_agenda_access
end
