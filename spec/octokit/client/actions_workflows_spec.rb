# frozen_string_literal: true

describe Octokit::Client::ActionsWorkflows do
  before do
    Octokit.reset!
    @client = oauth_client
  end

  describe '.workflows', :vcr do
    it 'returns the repository workflows' do
      @client.workflows(@test_repo)

      assert_requested :get, github_url("/repos/#{@test_repo}/actions/workflows")
    end

    it 'paginates the results' do
      @client.per_page = 1
      allow(@client).to receive(:paginate).and_call_original
      workflows = @client.workflows(@test_repo)

      expect(@client).to have_received(:paginate)
      expect(workflows.total_count).to eq(2)
      expect(workflows.workflows.count).to eq(1)
    end

    it 'auto-paginates the results' do
      @client.auto_paginate = true
      @client.per_page = 1
      allow(@client).to receive(:paginate).and_call_original
      workflows = @client.workflows(@test_repo)

      expect(@client).to have_received(:paginate)
      expect(workflows.total_count).to eq(2)
      expect(workflows.workflows.count).to eq(2)
    end
  end # .workflows

  describe '.workflow', :vcr do
    it 'returns the repository workflows' do
      workflow_file_name = 'simple_workflow.yml'
      request = stub_get("/repos/#{@test_repo}/actions/workflows/#{workflow_file_name}")

      @client.workflow(@test_repo, workflow_file_name)

      assert_requested request
    end
  end # .workflow

  describe '.workflow_dispatch', :vcr do
    it 'creates a workflow dispatch event' do
      workflow_file_name = 'simple_workflow.yml'
      request = stub_post("/repos/#{@test_repo}/actions/workflows/#{workflow_file_name}/dispatches")

      @client.workflow_dispatch(@test_repo, workflow_file_name, 'main')
      assert_requested request
    end

    context 'with return_run_details option' do
      it 'gets run details from API response' do
        wf_file = 'simple_workflow.yml'
        api_response_body = { id: 123, status: 'queued' }.to_json
        
        http_stub = stub_post("/repos/#{@test_repo}/actions/workflows/#{wf_file}/dispatches")
          .to_return(
            status: 200,
            body: api_response_body,
            headers: { 'Content-Type' => 'application/json' }
          )

        output = @client.workflow_dispatch(@test_repo, wf_file, 'main', return_run_details: true)
        
        expect(output.class.name).to eq('Sawyer::Resource')
        expect(output.id).to be(123)
        expect(output.status).to match('queued')
        assert_requested http_stub
      end
    end
  end # .workflow_dispatch

  describe '.workflow_enable' do
    it 'enables a workflow' do
      workflow_file_name = 'simple_workflow.yml'
      request = stub_put("/repos/#{@test_repo}/actions/workflows/#{workflow_file_name}/enable")

      @client.workflow_enable(@test_repo, workflow_file_name)
      assert_requested request
    end
  end # .workflow_enable

  describe '.workflow_disable' do
    it 'disables a workflow' do
      workflow_file_name = 'simple_workflow.yml'
      request = stub_put("/repos/#{@test_repo}/actions/workflows/#{workflow_file_name}/disable")

      @client.workflow_disable(@test_repo, workflow_file_name)
      assert_requested request
    end
  end # .workflow_disable
end
