defmodule FocalApi.DefaultTasks do

  def new_client_inquiry_tasks() do
    [
      %{ step: "Request More Information" },
      %{ step: "Save Client Information" },
    ]
  end

  def proposal_and_retainer_tasks() do
    [
      %{ step: "Send Proposal" },
      %{ step: "Commit To Proposal" },
      %{ step: "Receive Signed Proposal & Retainer" },
      %{ step: "Receive Retainer Fee" },
    ]
  end

  def engagement_tasks() do
    [
      %{ step: "Schedule Shoot Date" },
      %{ step: "Send 3 Week Pre Shoot Reminder" },
      %{ step: "Send 1 Week Pre Shoot Reminder" },
      %{ step: "Complete Shoot" },
      %{ step: "Send Thank You Email to Client" },
      %{ step: "Edit Engagement Images" },
      %{ step: "Share Gallery Link" },
      %{ step: "Create & Share Blog" },
    ]
  end

  def wedding_tasks() do
    [
      %{ step: "Schedule Shoot Date" },
      %{ step: "Send 4 Week Pre-Shoot Final Invoice" },
      %{ step: "Send 4 Week Pre Shoot Reminder" },
      %{ step: "Receive Remaining Balance" },
      %{ step: "Send 1 Week Pre Shoot Reminder" },
      %{ step: "Complete Shoot" },
      %{ step: "Send Thank You Email to Client" },
      %{ step: "Edit Wedding Images" },
      %{ step: "Share Gallery Link" },
      %{ step: "Create & Share Blog" },
    ]
  end

  def closeout_tasks() do
    [
      %{ step: "Request Feedback" },
      %{ step: "Save & Share Feedback" },
      %{ step: "Send Out Package Deliverables" },
      %{ step: "Send Out Gallery Link to Vendors" },
      %{ step: "Send Out 1 Year Anniversary Email" },
    ]
  end

end
