using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Zero_to_AI.Admin
{
    public partial class AdminSimulations : System.Web.UI.Page
    {
        private static string ConnStr => ConfigurationManager.ConnectionStrings["db"].ConnectionString;

        public class SimulationListItem
        {
            public int simulationId { get; set; }
            public string simulationName { get; set; }
        }

        public class RunsBySimItem
        {
            public int simulationId { get; set; }
            public string simulationName { get; set; }
            public int runCount { get; set; }
            public string lastRun { get; set; }
        }

        public class TopUserItem
        {
            public int userId { get; set; }
            public string userDisplay { get; set; }
            public int runCount { get; set; }
            public string lastRun { get; set; }
        }

        public class RecentRunItem
        {
            public string runTime { get; set; }
            public string userDisplay { get; set; }
            public string simulationName { get; set; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("~/ZerotoAI/Login.aspx");
                return;
            }

            string role = Convert.ToString(Session["UserRole"]);
            if (!role.Equals("Admin", StringComparison.OrdinalIgnoreCase))
            {
                Response.Redirect("~/ZerotoAI/Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                SetDefaultDates();
                LoadSimulationsDropdown();
                LoadDashboardData();
            }
        }

        private void SetDefaultDates()
        {
            txtToDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
            txtFromDate.Text = DateTime.Today.AddDays(-30).ToString("yyyy-MM-dd");
        }

        private void LoadSimulationsDropdown()
        {
            ddlSimulations.Items.Clear();
            ddlSimulations.Items.Add(new ListItem("All Simulations", "0"));

            using (SqlConnection conn = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("SELECT SimulationID, SimulationName FROM Simulations ORDER BY SimulationID;", conn))
            {
                conn.Open();
                using (SqlDataReader r = cmd.ExecuteReader())
                {
                    while (r.Read())
                    {
                        ddlSimulations.Items.Add(new ListItem(
                            Convert.ToString(r["SimulationName"]),
                            Convert.ToString(r["SimulationID"])
                        ));
                    }
                }
            }
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            LoadDashboardData();
        }

        private void LoadDashboardData()
        {
            try
            {
                DateTime from, to;
                if (!DateTime.TryParse(txtFromDate.Text, out from))
                    from = DateTime.Today.AddDays(-30);

                if (!DateTime.TryParse(txtToDate.Text, out to))
                    to = DateTime.Today;

                to = to.Date.AddDays(1).AddTicks(-1);

                int simulationId = 0;
                int.TryParse(ddlSimulations.SelectedValue, out simulationId);

                var runsBySimulation = new List<RunsBySimItem>();
                var topUsers = new List<TopUserItem>();
                var recentRuns = new List<RecentRunItem>();

                int totalRuns = 0;
                int uniqueUsers = 0;
                string mostUsed = "—";

                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    using (SqlCommand cmd = new SqlCommand(@"
                        SELECT
                            COUNT(*) AS TotalRuns,
                            COUNT(DISTINCT sr.UserID) AS UniqueUsers
                        FROM SimulationRuns sr
                        WHERE sr.RunTime >= @From AND sr.RunTime <= @To
                          AND (@SimID = 0 OR sr.SimulationID = @SimID);", conn))
                    {
                        cmd.Parameters.AddWithValue("@From", from);
                        cmd.Parameters.AddWithValue("@To", to);
                        cmd.Parameters.AddWithValue("@SimID", simulationId);

                        using (SqlDataReader r = cmd.ExecuteReader())
                        {
                            if (r.Read())
                            {
                                totalRuns = Convert.ToInt32(r["TotalRuns"]);
                                uniqueUsers = Convert.ToInt32(r["UniqueUsers"]);
                            }
                        }
                    }

                    using (SqlCommand cmd = new SqlCommand(@"
                        SELECT
                            s.SimulationID,
                            s.SimulationName,
                            COUNT(sr.RunID) AS RunCount,
                            MAX(sr.RunTime) AS LastRun
                        FROM Simulations s
                        LEFT JOIN SimulationRuns sr
                          ON sr.SimulationID = s.SimulationID
                         AND sr.RunTime >= @From AND sr.RunTime <= @To
                         AND (@SimID = 0 OR sr.SimulationID = @SimID)
                        GROUP BY s.SimulationID, s.SimulationName
                        ORDER BY RunCount DESC, s.SimulationID ASC;", conn))
                    {
                        cmd.Parameters.AddWithValue("@From", from);
                        cmd.Parameters.AddWithValue("@To", to);
                        cmd.Parameters.AddWithValue("@SimID", simulationId);

                        using (SqlDataReader r = cmd.ExecuteReader())
                        {
                            while (r.Read())
                            {
                                runsBySimulation.Add(new RunsBySimItem
                                {
                                    simulationId = Convert.ToInt32(r["SimulationID"]),
                                    simulationName = Convert.ToString(r["SimulationName"]),
                                    runCount = Convert.ToInt32(r["RunCount"]),
                                    lastRun = r["LastRun"] == DBNull.Value ? "—" : Convert.ToDateTime(r["LastRun"]).ToString("yyyy-MM-dd HH:mm")
                                });
                            }
                        }
                    }

                    if (runsBySimulation.Count > 0 && runsBySimulation[0].runCount > 0)
                    {
                        mostUsed = runsBySimulation[0].simulationName + " (" + runsBySimulation[0].runCount + ")";
                    }

                    using (SqlCommand cmd = new SqlCommand(@"
                        SELECT TOP 10
                            sr.UserID,
                            COALESCE(NULLIF(LTRIM(RTRIM(u.FirstName + ' ' + u.LastName)), ''), u.Username, CAST(sr.UserID AS varchar(20))) AS UserDisplay,
                            COUNT(*) AS RunCount,
                            MAX(sr.RunTime) AS LastRun
                        FROM SimulationRuns sr
                        LEFT JOIN Users u ON u.UserID = sr.UserID
                        WHERE sr.RunTime >= @From AND sr.RunTime <= @To
                          AND (@SimID = 0 OR sr.SimulationID = @SimID)
                        GROUP BY sr.UserID, u.FirstName, u.LastName, u.Username
                        ORDER BY RunCount DESC, LastRun DESC;", conn))
                    {
                        cmd.Parameters.AddWithValue("@From", from);
                        cmd.Parameters.AddWithValue("@To", to);
                        cmd.Parameters.AddWithValue("@SimID", simulationId);

                        using (SqlDataReader r = cmd.ExecuteReader())
                        {
                            while (r.Read())
                            {
                                topUsers.Add(new TopUserItem
                                {
                                    userId = Convert.ToInt32(r["UserID"]),
                                    userDisplay = Convert.ToString(r["UserDisplay"]),
                                    runCount = Convert.ToInt32(r["RunCount"]),
                                    lastRun = Convert.ToDateTime(r["LastRun"]).ToString("yyyy-MM-dd HH:mm")
                                });
                            }
                        }
                    }

                    using (SqlCommand cmd = new SqlCommand(@"
                        SELECT TOP 15
                            sr.RunTime,
                            COALESCE(NULLIF(LTRIM(RTRIM(u.FirstName + ' ' + u.LastName)), ''), u.Username, CAST(sr.UserID AS varchar(20))) AS UserDisplay,
                            s.SimulationName
                        FROM SimulationRuns sr
                        LEFT JOIN Users u ON u.UserID = sr.UserID
                        LEFT JOIN Simulations s ON s.SimulationID = sr.SimulationID
                        WHERE sr.RunTime >= @From AND sr.RunTime <= @To
                          AND (@SimID = 0 OR sr.SimulationID = @SimID)
                        ORDER BY sr.RunTime DESC;", conn))
                    {
                        cmd.Parameters.AddWithValue("@From", from);
                        cmd.Parameters.AddWithValue("@To", to);
                        cmd.Parameters.AddWithValue("@SimID", simulationId);

                        using (SqlDataReader r = cmd.ExecuteReader())
                        {
                            while (r.Read())
                            {
                                recentRuns.Add(new RecentRunItem
                                {
                                    runTime = Convert.ToDateTime(r["RunTime"]).ToString("yyyy-MM-dd HH:mm"),
                                    userDisplay = Convert.ToString(r["UserDisplay"]),
                                    simulationName = Convert.ToString(r["SimulationName"])
                                });
                            }
                        }
                    }
                }

                lblTotalRuns.Text = totalRuns.ToString();
                lblUniqueUsers.Text = uniqueUsers.ToString();
                lblMostUsed.Text = mostUsed;

                lblStatus.Text = "Analytics loaded successfully.";
                lblStatus.CssClass = "text-success"; // Fixed!
                lblStatus.Visible = true; // Added!

                repRunsBySimulation.DataSource = runsBySimulation;
                repRunsBySimulation.DataBind();

                repTopUsers.DataSource = topUsers;
                repTopUsers.DataBind();

                repRecentRuns.DataSource = recentRuns;
                repRecentRuns.DataBind();
            }
            catch (Exception ex)
            {
                lblStatus.Text = "Failed to load analytics: " + ex.Message;
                lblStatus.CssClass = "text-error"; // Fixed!
                lblStatus.Visible = true; // Added!
            }
        }
    }
}