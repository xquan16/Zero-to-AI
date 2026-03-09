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
            CheckLoginStatus();

            // Add the Guest Popup logic ONLY if they are not logged in
            if (Session["UserRole"] == null)
            {
                string loginUrl = ResolveClientUrl("~/ZerotoAI/Login.aspx");
                string guestPopupJS = $"if(confirm('You haven\\'t logged in yet. Go to the Login page?')) {{ window.location.href='{loginUrl}'; }} return false;";

                quizzesBtn.OnClientClick = guestPopupJS;
                coursesBtn.OnClientClick = guestPopupJS;
                simBtn.OnClientClick = guestPopupJS;
            }
            else
            {
                // 3. Clear the popup if they ARE logged in, so they can click normally
                quizzesBtn.OnClientClick = "";
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
            Response.Redirect("~/ZerotoAI/Login.aspx");
        }

        protected void quizzesBtn_Click(object sender, EventArgs e)
        {
            // 1. Check if the user is a Guest
            if (Session["UserRole"] == null)
            {
                Response.Redirect("~/ZerotoAI/Login.aspx");
                return;
            }

            // 2. Read the role and redirect to the correct module
            string role = Session["UserRole"].ToString();

            if (role == "Admin")
            {
                Response.Redirect("~/Admin/AdminMonitorQuiz.aspx");
            }
            else if (role == "Editor")
            {
                Response.Redirect("~/Editor/EditorEditQuiz.aspx");
            }
            else if (role == "Member")
            {
                Response.Redirect("~/Member/QuizTopic.aspx");
            }
            else
            {
                Response.Redirect("~/ZerotoAI/Login.aspx");
            }
        }


        protected void coursesBtn_Click(object sender, EventArgs e)
        {
            // 1. Check if the user is a Guest
            if (Session["UserRole"] == null)
            {
                Response.Redirect("~/ZerotoAI/Login.aspx");
                return;
            }

            // 2. Read the role and redirect to the correct module
            string role = Session["UserRole"].ToString();

            if (role == "Admin")
            {
                Response.Redirect("~/Admin/AdminCourses.aspx");
            }
            else if (role == "Editor")
            {
                Response.Redirect("~/Editor/EditorCourses.aspx");
            }
            else if (role == "Member")
            {
                Response.Redirect("~/Member/Courses.aspx");
            }
            else
            {
                Response.Redirect("~/ZerotoAI/Login.aspx");
            }
        }


        protected void simBtn_Click(object sender, EventArgs e)
        {
            // 1. Check if the user is a Guest
            if (Session["UserRole"] == null)
            {
                Response.Redirect("~/ZerotoAI/Login.aspx");
                return;
            }

            // 2. Read the role and redirect to the correct module
            string role = Session["UserRole"].ToString();

            if (role == "Admin")
            {
                Response.Redirect("~/Admin/AdminSimulations.aspx");
            }
            else if (role == "Editor")
            {
                Response.Redirect("~/Editor/EditorSimulations.aspx");
            }
            else if (role == "Member")
            {
                Response.Redirect("~/Member/Simulations.aspx");
            }
            else
            {
                Response.Redirect("~/ZerotoAI/Login.aspx");
            }
        }

    }
}