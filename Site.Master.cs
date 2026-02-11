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
            // Check if user is logged in (Change "UserRole" to whatever session key you plan to use)
            if (Session["UserRole"] != null)
            {
                // Show Member Panel
                guestPanel.Visible = false;
                memberPanel.Visible = true;

                // Set Labels
                roleLbl.Text = Session["UserRole"].ToString(); // e.g., "Student"
                usernameLbl.Text = Session["Username"].ToString(); // e.g., "Alex"
            }
            else
            {
                // Show Guest Panel
                guestPanel.Visible = true;
                memberPanel.Visible = false;
            }
        }

        protected void logoutBtn_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Home.aspx");
        }
    }
}