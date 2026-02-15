using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ZerotoAI
{
    public partial class Site : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                CheckLoginStatus();
            }
        }

        private void CheckLoginStatus()
        {
            if (Session["UserRole"] != null)
            {
                string role = Session["UserRole"].ToString();
                string username = Session["Username"].ToString();

                roleLbl.Text = role;
                usernameLbl.Text = username;

                // Apply Theme Color
                masterBody.Attributes["data-role"] = role.ToLower();

                // --- NEW: Load Profile Picture ---
                if (Session["UserProfilePic"] != null && !string.IsNullOrEmpty(Session["UserProfilePic"].ToString()))
                {
                    imgUserProfile.ImageUrl = "~/images/" + Session["UserProfilePic"].ToString();
                }
                else
                {
                    // Fallback if session is empty or null
                    imgUserProfile.ImageUrl = "~/images/default_user.png";
                }

                guestPanel.Visible = false;
                memberPanel.Visible = true;
            }
            else
            {
                // Guest Mode
                guestPanel.Visible = true;
                memberPanel.Visible = false;

                // Remove role attribute (Default Blue)
                masterBody.Attributes.Remove("data-role");
            }
        }

        protected void logoutBtn_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }
    }
}