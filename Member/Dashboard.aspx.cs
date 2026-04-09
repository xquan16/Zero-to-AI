using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Zero_to_AI.Member
{
    public partial class Dashboard : System.Web.UI.Page
    {
        private readonly string _conn = ConfigurationManager.ConnectionStrings["db"].ConnectionString;

        // 1. Get Logged-in User
        private int CurrentUserID
        {
            get
            {
                if (Session["UserID"] != null)
                {
                    return Convert.ToInt32(Session["UserID"]);
                }
                return 0;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            // 2. Security Check
            if (CurrentUserID == 0 || Session["UserRole"] == null || Session["UserRole"].ToString() != "Member")
            {
                Response.Redirect("~/ZerotoAI/Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                // Set the personalized welcome banner
                string username = Session["Username"] != null ? Session["Username"].ToString() : "Member";
                lblWelcome.Text = "Welcome Back, " + username + "!";

                // Load the data
                LoadMemberStats();
                LoadFeedbackInbox();
            }
        }

        // 3. Load The 3 Pillars (Stats)
        private void LoadMemberStats()
        {
            int uid = CurrentUserID;
            int coursesCompleted = 0;
            int avgQuizScore = 0;
            int simsCleared = 0;

            using (SqlConnection conn = new SqlConnection(_conn))
            {
                conn.Open();

                // Count completed courses
                string sqlCourses = "SELECT COUNT(*) FROM CourseProgress WHERE UserID = @uid";
                using (SqlCommand cmd = new SqlCommand(sqlCourses, conn))
                {
                    cmd.Parameters.AddWithValue("@uid", uid);
                    object res = cmd.ExecuteScalar();
                    if (res != null && res != DBNull.Value) coursesCompleted = Convert.ToInt32(res);
                }

                // Average out all their quiz scores
                string sqlQuizzes = "SELECT AVG(Score) FROM UserProgress WHERE UserID = @uid";
                using (SqlCommand cmd = new SqlCommand(sqlQuizzes, conn))
                {
                    cmd.Parameters.AddWithValue("@uid", uid);
                    object res = cmd.ExecuteScalar();
                    if (res != null && res != DBNull.Value) avgQuizScore = Convert.ToInt32(res);
                }

                // Count UNIQUE Simulations Cleared
                string sqlSims = "SELECT COUNT(*) FROM SimulationRuns WHERE UserID = @uid";
                using (SqlCommand cmd = new SqlCommand(sqlSims, conn))
                {
                    cmd.Parameters.AddWithValue("@uid", uid);
                    object res = cmd.ExecuteScalar();
                    if (res != null && res != DBNull.Value) simsCleared = Convert.ToInt32(res);
                }
            }

            // Update the UI labels
            lblMemCourses.Text = coursesCompleted.ToString();
            lblMemQuizzes.Text = avgQuizScore.ToString() + "%";
            lblMemSims.Text = simsCleared.ToString();
        }

        // 4. Load Feedback History
        private void LoadFeedbackInbox()
        {
            string sql = "SELECT Date, Message, AdminReply FROM Feedback WHERE UserID = @uid ORDER BY Date DESC";

            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(_conn))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@uid", CurrentUserID);
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }
            }

            if (dt.Rows.Count > 0)
            {
                rptMyFeedback.DataSource = dt;
                rptMyFeedback.DataBind();
                rptMyFeedback.Visible = true;
                lblNoFeedbackMem.Visible = false;
            }
            else
            {
                rptMyFeedback.Visible = false;
                lblNoFeedbackMem.Visible = true;
            }
        }

        // 5. Submit New Feedback
        protected void btnSendFeedback_Click(object sender, EventArgs e)
        {
            string msg = txtFeedbackMsg.Text.Trim();
            if (string.IsNullOrEmpty(msg)) return;

            string sql = "INSERT INTO Feedback (UserID, Message, Status, Date) VALUES (@uid, @msg, 'Unread', GETDATE())";

            using (SqlConnection conn = new SqlConnection(_conn))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@uid", CurrentUserID);
                cmd.Parameters.AddWithValue("@msg", msg);
                conn.Open();
                cmd.ExecuteNonQuery();
            }

            // Clear the textbox and show success message
            txtFeedbackMsg.Text = "";
            lblMessage.Text = "<i class='fas fa-check-circle'></i> Your feedback has been sent to the Admin!";
            lblMessage.Visible = true;

            // Refresh the inbox to show the newly sent message
            LoadFeedbackInbox();
        }
    }
}