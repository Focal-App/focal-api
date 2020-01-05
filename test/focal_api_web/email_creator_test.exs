defmodule FocalApiWeb.EmailCreatorTest do
  use ExUnit.Case
  alias FocalApiWeb.EmailCreator
  alias FocalApi.IncomingEmail

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

  test "can set multiple recipients with array" do
    crlf = "\r\n"
    subject = "Hello From Focal"
    recipient = "mary@mail.com"
    recipient_2 = "jane@mail.com"
    content = "<div>Hello!</div>"

    email =
      EmailCreator.new()
      |> EmailCreator.set_subject(subject)
      |> EmailCreator.set_multiple_recipients([recipient, recipient_2])
      |> EmailCreator.set_content(content)
      |> EmailCreator.generate()

    assert email ==
             "MIME-Version: 1.0#{crlf}Subject: Hello From Focal#{crlf}From: me#{crlf}To: mary@mail.com, jane@mail.com#{
               crlf
             }Content-Type: text/html; charset=\"UTF-8\"#{crlf}Content-Transfer-Encoding: quoted-printable#{
               crlf
             }#{crlf}<div>Hello!</div>"
  end

  test "generates full gmail compliant email message" do
    mail_data = %IncomingEmail{
      sender: "fsadikin@mail.com",
      recipients: ["jane@mail.com", "mary@mail.com"],
      subject: "Hello from focal",
      content: "<div><h1>Hiya!</h1></div>"
    }

    email = EmailCreator.gmail_generator(mail_data)

    assert email.raw ==
             "TUlNRS1WZXJzaW9uOiAxLjANClN1YmplY3Q6IEhlbGxvIGZyb20gZm9jYWwNCkZyb206IGZzYWRpa2luQG1haWwuY29tDQpUbzogamFuZUBtYWlsLmNvbSwgbWFyeUBtYWlsLmNvbQ0KQ29udGVudC1UeXBlOiB0ZXh0L2h0bWw7IGNoYXJzZXQ9IlVURi04Ig0KQ29udGVudC1UcmFuc2Zlci1FbmNvZGluZzogcXVvdGVkLXByaW50YWJsZQ0KDQo8ZGl2PjxoMT5IaXlhITwvaDE-PC9kaXY-"
  end
end
