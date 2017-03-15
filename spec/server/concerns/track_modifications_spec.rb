require_relative "../spec_helper"


describe Lanes::Concerns::TrackModifications do

    include TestingModels

    it 'decorates a class' do
        with_testing_models do
            Lanes::User.scoped_to(1) do
                TestModel.tracks_user_modifications
                tm = TestModel.create
                expect(tm.created_by_id).to eq(1)
                expect(tm.updated_by_id).to eq(1)
            end
        end
    end
end
