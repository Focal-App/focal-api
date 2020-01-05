defmodule EmailData do
  defstruct subject: "", sender: "me", recipient: "", content: ""
end

defmodule FocalApiWeb.EmailCreator do
  def new do
    %EmailData{}
  end

  def set_subject(email_data, subject) do
    %{email_data | subject: subject}
  end

  def set_receipient(email_data, recipient) do
    updated_recipient =
      case email_data.recipient do
        "" -> recipient
        _ -> "#{email_data.recipient}, #{recipient}"
      end

    %{email_data | recipient: updated_recipient}
  end

  def set_content(email_data, content) do
    %{email_data | content: content}
  end

  def set_sender(email_data, sender) do
    %{email_data | sender: sender}
  end

  def generate(email_data) do
    crlf = "\r\n"
    mime_version = "MIME-Version: 1.0#{crlf}"
    subject_line = "Subject: #{email_data.subject}#{crlf}"
    sender_line = "From: #{email_data.sender}#{crlf}"
    recipient_line = "To: #{email_data.recipient}#{crlf}"
    content_type_line = "Content-Type: text/html; charset=\"UTF-8\"#{crlf}"
    content_transfer_encoding_line = "Content-Transfer-Encoding: quoted-printable#{crlf}"

    "#{mime_version}#{subject_line}#{sender_line}#{recipient_line}#{content_type_line}#{
      content_transfer_encoding_line
    }#{crlf}#{email_data.content}"
  end
end
