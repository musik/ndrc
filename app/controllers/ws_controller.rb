class WsController < ApplicationController
  include WashOut::SOAP
  soap_action "company_add",
    :args=>{:cpID=>:string,:cpName=>:string},
    :return=>{:CmdState=>:integer}
  def company_add
    #insert company
    render :soap=>2
  end
end
