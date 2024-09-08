library(shiny)

# Custom login page style with updated color palette --------
login_page_style <-HTML(
  "
        body {
        background: #195F16; /* Changed background to the first color in the palette */
        background: -webkit-linear-gradient(to bottom, #1C1D46, #00ffff); /* Chrome 10-25, Safari 5.1-6 */
        background: linear-gradient(to bottom, #1C1D46, #00ffff); /* W3C, IE 10+/ Edge, Firefox 16+, Chrome 26+, Opera 12+, Safari 7+ */
        color: #000000; /* Dark text color */
        font-family: 'Verdana', sans-serif; /* Font remains Verdana */
      }
      #login-page {
        position: absolute;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        background-color: #ffffff; /* White background for the login container */
        border: 1px solid #2d677d; /* Border color from the palette */
        border-radius: 12px; /* Border-radius remains the same */
        padding: 45px; /* Padding remains the same */
        box-shadow: 0 6px 12px rgba(0, 0, 0, 0.15); /* Slightly stronger shadow remains */
        text-align: center;
        max-width: 420px; /* Max-width remains the same */
      }
      .login-header {
        margin-bottom: 35px; /* Space below header remains the same */
        font-size: 26px; /* Font size remains the same */
        color: #2d677d; /* Dark header color from the palette */
      }
      .form-group {
        margin-bottom: 25px; /* Margin remains the same */
      }
      .btn-primary {
        background-color: #2d677d; /* Changed button color to match the darker palette color */
        color: #fff; /* White text */
        border-color: #2d677d; /* Border color matching the button */
        transition: all 0.3s ease;
      }
      .btn-secondary {
        background-color: #2d677d; /* Changed button color to match the darker palette color */
        color: #fff; /* White text */
        border-color: #2d677d; /* Border color matching the button */
        transition: all 0.3s ease;
      }
      .btn-primary:hover {
        background-color: #000000; /* Black hover color */
        border-color: #000000;
      }
      .btn-secondary:hover {
        background-color: #000000; /* Black hover color */
        border-color: #000000;
      }
  "
)
  


# Style for notifications
global_modal_style <- HTML(
  "
    /* Add your custom styles here */
    .modal-header {
      background-color: #4898a8; /* Set the background color of the header */
      color: white; /* Set the text color of the header */
    }
    .modal-footer {
      background-color: #4898a8; /* Set the background color of the footer */
    }
  "
)

# style for logout button
logout_button_style <- "background-color: white !important; border: 0; border-radius: 20px; font-weight: bold; margin:5px; padding: 4px;"
