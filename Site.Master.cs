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

                // --- Load Profile Picture ---
                if (Session["UserProfilePic"] != null && !string.IsNullOrEmpty(Session["UserProfilePic"].ToString()))
                {
                    imgUserProfile.ImageUrl = "~/images/" + Session["UserProfilePic"].ToString();
                }
                else
                {
                    // Fallback if session is empty or null
                    imgUserProfile.ImageUrl = "~/images/default_user.png";
                }

                // Logged In Mode (Admin, Editor, Member)
                guestPanel.Visible = false;
                memberPanel.Visible = true;

                string currentPath = Request.Url.AbsolutePath;
                bool isQuizPage = currentPath.EndsWith("/Quiz.aspx", StringComparison.OrdinalIgnoreCase) ||
                                  currentPath.EndsWith("/Quiz", StringComparison.OrdinalIgnoreCase);

                // Only turn Zoa on if the user is a Member AND they are NOT taking a quiz!
                zoaPanel.Visible = (role == "Member" && !isQuizPage);
            }
            else
            {
                // Guest Mode
                guestPanel.Visible = true;
                memberPanel.Visible = false;

                // Remove role attribute (Default Blue)
                masterBody.Attributes.Remove("data-role");

                // Make sure Zoa is hidden from guests!
                zoaPanel.Visible = false;
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


        protected void dashboardBtn_Click(object sender, EventArgs e)
        {
            string role = Session["UserRole"].ToString();

            if (role == "Admin")
            {
                Response.Redirect("~/Admin/AdminDashboard.aspx");
            }
            else if (role == "Editor")
            {
                Response.Redirect("~/Editor/EditorDashboard.aspx");
            }
            else if (role == "Member")
            {
                Response.Redirect("~/Member/Dashboard.aspx");
            }
            else
            {
                Response.Redirect("~/ZerotoAI/Home.aspx");
            }
        }
    }
}