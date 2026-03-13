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
                        INSERT INTO SimulationRuns (UserID, SimulationID)
                        VALUES (@UserID, @SimulationID);";

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
    }
}