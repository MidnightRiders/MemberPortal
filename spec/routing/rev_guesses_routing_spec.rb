require "spec_helper"

describe RevGuessesController do
  describe "routing" do

    it "routes to #index" do
      get("/rev_guesses").should route_to("rev_guesses#index")
    end

    it "routes to #new" do
      get("/rev_guesses/new").should route_to("rev_guesses#new")
    end

    it "routes to #show" do
      get("/rev_guesses/1").should route_to("rev_guesses#show", :id => "1")
    end

    it "routes to #edit" do
      get("/rev_guesses/1/edit").should route_to("rev_guesses#edit", :id => "1")
    end

    it "routes to #create" do
      post("/rev_guesses").should route_to("rev_guesses#create")
    end

    it "routes to #update" do
      put("/rev_guesses/1").should route_to("rev_guesses#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/rev_guesses/1").should route_to("rev_guesses#destroy", :id => "1")
    end

  end
end
