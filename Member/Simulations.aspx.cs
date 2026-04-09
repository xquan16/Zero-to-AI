using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Zero_to_AI.Member
{
    public partial class Simulations : System.Web.UI.Page
    {
        private static string ConnStr => ConfigurationManager.ConnectionStrings["db"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("~/ZerotoAI/Login.aspx");
                return;
            }
        }

        [WebMethod(EnableSession = true)]
        public static object LogSimulationAjax(int simulationId)
        {
            try
            {
                if (HttpContext.Current?.Session?["UserID"] == null)
                {
                    return new { ok = false, message = "User not logged in." };
                }

                int userId = Convert.ToInt32(HttpContext.Current.Session["UserID"]);

                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    const string sql = @"
                        INSERT INTO SimulationRuns (UserID, SimulationID, RunTime)
                        VALUES (@UserID, @SimulationID, GETDATE());";

                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserID", userId);
                        cmd.Parameters.AddWithValue("@SimulationID", simulationId);

                        int rows = cmd.ExecuteNonQuery();

                        return new
                        {
                            ok = true,
                            message = "Simulation logged successfully.",
                            rows = rows,
                            userId = userId,
                            simulationId = simulationId
                        };
                    }
                }
            }
            catch (Exception ex)
            {
                return new { ok = false, message = ex.Message };
            }
        }

        protected void btnHiddenLog_Click(object sender, EventArgs e)
        {
            // 1. Double check the user is logged in
            if (Session["UserID"] == null) return;

            int userId = Convert.ToInt32(Session["UserID"]);
            int simulationId = 0;

            // 2. Safely grab the Simulation ID from the hidden field
            if (int.TryParse(hfSimId.Value, out simulationId))
            {
                try
                {
                    using (SqlConnection conn = new SqlConnection(ConnStr))
                    {
                        conn.Open();

                        const string sql = @"
                            INSERT INTO SimulationRuns (UserID, SimulationID, RunTime)
                            VALUES (@UserID, @SimulationID, GETDATE());";

                        using (SqlCommand cmd = new SqlCommand(sql, conn))
                        {
                            cmd.Parameters.AddWithValue("@UserID", userId);
                            cmd.Parameters.AddWithValue("@SimulationID", simulationId);

                            cmd.ExecuteNonQuery();

                            // SUCCESS MESSAGE
                            lblSimDebug.Text = "<span style='color:#10b981;'><i class='fas fa-check'></i> Run recorded successfully!</span>";
                        }
                    }
                }
                catch (Exception ex)
                {
                    // ERROR MESSAGE: Prints the exact SQL failure to your screen
                    lblSimDebug.Text = "<span style='color:#ef4444;'><i class='fas fa-exclamation-triangle'></i> SQL Error: " + ex.Message + "</span>";
                }
            }
            else
            {
                lblSimDebug.Text = "<span style='color:#f59e0b;'>Error: JavaScript failed to send Simulation ID.</span>";
            }
        }
    }
}