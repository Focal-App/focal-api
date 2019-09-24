defmodule FocalApi.DefaultTasks do

  def new_client_inquiry_tasks() do
    [
      %{ step: "Request More Information", order: 0 },
      %{ step: "Save Client Information", order: 1 },
    ]
  end

  def proposal_and_retainer_tasks() do
    [
      %{ step: "Send Proposal", order: 100 },
      %{ step: "Commit To Proposal", order: 101 },
      %{ step: "Receive Signed Proposal & Retainer", order: 102 },
      %{ step: "Receive Retainer Fee", order: 103 },
    ]
  end

  def engagement_tasks() do
    [
      %{ step: "Schedule Shoot Date", order: 200 },
      %{ step: "Send 3 Week Pre Shoot Reminder", order: 201 },
      %{ step: "Send 1 Week Pre Shoot Reminder", order: 202 },
      %{ step: "Complete Shoot", order: 203 },
      %{ step: "Send Thank You Email to Client", order: 204 },
      %{ step: "Edit Engagement Images", order: 205 },
      %{ step: "Share Gallery Link", order: 206 },
      %{ step: "Create & Share Blog", order: 207 },
    ]
  end

  def wedding_tasks() do
    [
      %{ step: "Schedule Shoot Date", order: 300 },
      %{ step: "Send 4 Week Pre-Shoot Final Invoice", order: 301 },
      %{ step: "Send 4 Week Pre Shoot Reminder", order: 302 },
      %{ step: "Receive Remaining Balance", order: 303 },
      %{ step: "Send 1 Week Pre Shoot Reminder", order: 304 },
      %{ step: "Complete Shoot", order: 305 },
      %{ step: "Send Thank You Email to Client", order: 306 },
      %{ step: "Edit Wedding Images", order: 307 },
      %{ step: "Share Gallery Link", order: 308 },
      %{ step: "Create & Share Blog", order: 309 },
    ]
  end

  def closeout_tasks() do
    [
      %{ step: "Request Feedback", order: 400 },
      %{ step: "Save & Share Feedback", order: 401 },
      %{ step: "Send Out Package Deliverables", order: 402 },
      %{ step: "Send Out Gallery Link to Vendors", order: 403 },
      %{ step: "Send Out 1 Year Anniversary Email", order: 404 },
    ]
  end

end
