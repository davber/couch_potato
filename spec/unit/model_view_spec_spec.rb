require 'spec_helper'

describe CouchPotato::View::ModelViewSpec, 'map_function' do
  it "should include conditions" do
    spec = CouchPotato::View::ModelViewSpec.new Object, 'all', {:conditions => 'doc.closed = true'}, {}
    spec.map_function.should include("if(doc.#{CouchPotato.type_field} && doc.#{CouchPotato.type_field} == 'Object' && (doc.closed = true))")
  end
  
  it "should not include conditions when they are nil" do
    spec = CouchPotato::View::ModelViewSpec.new Object, 'all', {}, {}
    spec.map_function.should include("if(doc.#{CouchPotato.type_field} && doc.#{CouchPotato.type_field} == 'Object')")
  end
end
