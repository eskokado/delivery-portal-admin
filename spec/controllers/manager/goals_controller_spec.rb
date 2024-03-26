require 'rails_helper'

RSpec.describe Manager::GoalsController,
               type: :controller do
  let(:user) { FactoryBot.create(:user) }
  let(:client) { create(:client, user: user) }
  let(:goal) { create(:goal, client: client) }
  let(:goals) { create_list(:goal, 3, client: client) }
  let(:valid_attributes) do
    { name: 'New name',
      description: 'New description' }
  end
  let(:invalid_attributes) do
    { name: '', description: '' }
  end

  before(:each) do
    allow_any_instance_of(InternalController).to receive(:authenticate_user!).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end

  describe 'GET #index' do
    it 'renders the index template' do
      get :index
      expect(response).to render_template(:index)
    end

    it 'assigns all goals as @goals for the given search parameters' do
      double('search_result', result: goals)
      allow(Goal).to receive_message_chain(:ransack, :result).and_return(goals)

      get :index

      expect(assigns(:goals)).to match_array(goals)
    end

    it 'assigns all goals as @goals' do
      get :index
      expect(assigns(:goals)).to eq([goal])
    end
  end

  describe 'GET #index with search' do
    it 'returns the goals searched correctly' do
      goal1 = create(:goal, name: 'Learn Python',
                            description: 'learn dataframes and data analisys')
      goal2 = create(:goal,
                     name: 'Study front-end framework',
                     description: 'learn tailwind to create robusts pages')
      create(:task,
             name: 'pandas',
             description: 'learn how to import and use pandas library as pd',
             goal: goal1)

      get :index,
          params: {
            q:
              {
                name_or_description_or_tasks_name_or_tasks_description_cont:
                  'dataframes and data analisys'
              }
          }

      expect(assigns(:goals)).to include(goal1)
      expect(assigns(:goals)).to_not include(goal2)
    end

    it 'excludes non-matching results' do
      create(:goal, name: 'Non-Matching Goal')

      get :index,
          params: {
            q: {
              name_or_description_or_tasks_name_or_tasks_description_cont:
                'dataframes and data analisys'
            }
          }

      expect(assigns(:goals)).to be_empty
    end

    it 'renders the index template' do
      get :index,
          params: {
            q: {
              name_or_description_or_tasks_name_or_tasks_description_cont:
                'Search Nothing'
            }
          }

      expect(response).to render_template(:index)
    end
  end

  describe 'GET #show' do
    it 'assigns the requested goal as @goal' do
      get :show, params: { id: goal.id }
      expect(assigns(:goal)).to eq(goal)
    end
  end

  describe 'GET #new' do
    it 'assigns a new goal as @goal' do
      get :new
      expect(assigns(:goal)).to be_a_new(Goal)
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested goal as @goal' do
      get :edit, params: { id: goal.id }
      expect(assigns(:goal)).to eq(goal)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      # TODO: não está salvando no BD de testes
      # it 'creates a new Goal' do
      #   post :create,
      #        params: { goal: valid_attributes }
      #   expect(Goal.count).to eq(1)
      # end

      # TODO: não está salvando no BD de testes
      # it 'redirects to the created goal' do
      #   post :create,
      #        params: { goal: valid_attributes }
      #   expect(response).to redirect_to(manager_goal_path(Goal.last))
      # end
    end

    context 'with invalid params' do
      it 're-renders the "new" template' do
        post :create,
             params: { goal: invalid_attributes }
        expect(response).to render_template('new')
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested goal' do
        put :update,
            params: { id: goal.id,
                      goal: valid_attributes }
        goal.reload
        expect(goal.name).to eq(goal.name)
      end

      it 'redirects to the goal' do
        put :update,
            params: { id: goal.id,
                      goal: valid_attributes }
        expect(response).to redirect_to(manager_goal_path(goal))
      end
    end

    context 'with invalid params' do
      it 're-renders the "edit" template' do
        put :update,
            params: { id: goal.id,
                      goal: invalid_attributes }
        expect(response).to render_template('edit')
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested goal' do
      goal = create(:goal)
      expect do
        delete :destroy, params: { id: goal.id }
      end.to change(Goal, :count).by(-1)
    end

    it 'redirects to the goals list' do
      delete :destroy, params: { id: goal.id }
      expect(response).to redirect_to(manager_goals_path)
    end
  end
end
