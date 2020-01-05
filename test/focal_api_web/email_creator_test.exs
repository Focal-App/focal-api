defmodule FocalApiWeb.EmailCreatorTest do
  use ExUnit.Case
  alias FocalApiWeb.EmailCreator

  test "generates simple email with single recipient" do
    crlf = "\r\n"
    subject = "Hello From Focal"
    recipient = "mary@mail.com"
    content = "<div>Hello!</div>"

    email =
      EmailCreator.new()
      |> EmailCreator.set_subject(subject)
      |> EmailCreator.set_receipient(recipient)
      |> EmailCreator.set_content(content)
      |> EmailCreator.generate()

    assert email ==
             "MIME-Version: 1.0#{crlf}Subject: Hello From Focal#{crlf}From: me#{crlf}To: mary@mail.com#{
               crlf
             }Content-Type: text/html; charset=\"UTF-8\"#{crlf}Content-Transfer-Encoding: quoted-printable#{
               crlf
             }#{crlf}<div>Hello!</div>"
  end

  test "generates simple email with multiple recipients" do
    crlf = "\r\n"
    subject = "Hello From Focal"
    recipient = "mary@mail.com"
    recipient_2 = "jane@mail.com"
    content = "<div>Hello!</div>"

    email =
      EmailCreator.new()
      |> EmailCreator.set_subject(subject)
      |> EmailCreator.set_receipient(recipient)
      |> EmailCreator.set_receipient(recipient_2)
      |> EmailCreator.set_content(content)
      |> EmailCreator.generate()

    assert email ==
             "MIME-Version: 1.0#{crlf}Subject: Hello From Focal#{crlf}From: me#{crlf}To: mary@mail.com, jane@mail.com#{
               crlf
             }Content-Type: text/html; charset=\"UTF-8\"#{crlf}Content-Transfer-Encoding: quoted-printable#{
               crlf
             }#{crlf}<div>Hello!</div>"
  end

  test "generates simple email with custom from" do
    crlf = "\r\n"
    subject = "Hello From Focal"
    from = "francesca <test@gmail.com>"
    recipient = "mary@mail.com"
    content = "<div>Hello!</div>"

    email =
      EmailCreator.new()
      |> EmailCreator.set_sender(from)
      |> EmailCreator.set_subject(subject)
      |> EmailCreator.set_receipient(recipient)
      |> EmailCreator.set_content(content)
      |> EmailCreator.generate()

    assert email ==
             "MIME-Version: 1.0#{crlf}Subject: Hello From Focal#{crlf}From: francesca <test@gmail.com>#{
               crlf
             }To: mary@mail.com#{crlf}Content-Type: text/html; charset=\"UTF-8\"#{crlf}Content-Transfer-Encoding: quoted-printable#{
               crlf
             }#{crlf}<div>Hello!</div>"
  end
end
