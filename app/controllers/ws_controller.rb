class WsController < ApplicationController
  include WashOut::SOAP
  soap_action "company_add",
    :args=>{:cpID=>:string,:cpName=>:string},
    :return=>{:CmdState=>:integer}
  def company_add
    #insert company
    render :soap=>{:CmdState=>1}
  end
  before_filter :dump_parameters
  def dump_parameters
    Rails.logger.debug params.inspect
  end
end
