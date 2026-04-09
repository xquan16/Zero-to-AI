using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Zero_to_AI.Editor
{
    public partial class EditorSimulations : System.Web.UI.Page
    {
        private static string ConnStr => ConfigurationManager.ConnectionStrings["db"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("~/ZerotoAI/Login.aspx");
                return;
            }

            string role = Convert.ToString(Session["UserRole"]);

            if (!role.Equals("Editor", StringComparison.OrdinalIgnoreCase) &&
                !role.Equals("Admin", StringComparison.OrdinalIgnoreCase))
            {
                Response.Redirect("~/ZerotoAI/Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadSimulationCard(1, txtDesc1, ddlStatus1, lblPill1, lblMsg1);
                LoadSimulationCard(2, txtDesc2, ddlStatus2, lblPill2, lblMsg2);
                LoadSimulationCard(3, txtDesc3, ddlStatus3, lblPill3, lblMsg3);
            }
        }

        private void LoadSimulationCard(
            int simulationId,
            System.Web.UI.WebControls.TextBox txtDesc,
            System.Web.UI.WebControls.DropDownList ddlStatus,
            System.Web.UI.WebControls.Label lblPill,
            System.Web.UI.WebControls.Label lblMsg)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT Description, Status
                    FROM Simulations
                    WHERE SimulationID = @SimulationID;", conn))
                {
                    cmd.Parameters.AddWithValue("@SimulationID", simulationId);
                    conn.Open();

                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            string description = r["Description"] == DBNull.Value ? "" : Convert.ToString(r["Description"]);
                            string status = r["Status"] == DBNull.Value ? "Active" : Convert.ToString(r["Status"]);

                            txtDesc.Text = description;

                            if (ddlStatus.Items.FindByValue(status) != null)
                                ddlStatus.SelectedValue = status;
                            else
                                ddlStatus.SelectedValue = "Active";

                            lblPill.Text = status;
                            lblMsg.Visible = false; // Hide on load
                        }
                        else
                        {
                            lblMsg.Text = "Simulation not found.";
                            lblMsg.CssClass = "text-error";
                            lblMsg.Visible = true;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                lblMsg.Text = "Load failed: " + ex.Message;
                lblMsg.CssClass = "text-error";
                lblMsg.Visible = true;
            }
        }

        private void SaveSimulationCard(
            int simulationId,
            System.Web.UI.WebControls.TextBox txtDesc,
            System.Web.UI.WebControls.DropDownList ddlStatus,
            System.Web.UI.WebControls.Label lblPill,
            System.Web.UI.WebControls.Label lblMsg)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                using (SqlCommand cmd = new SqlCommand(@"
                    UPDATE Simulations
                    SET Description = @Description,
                        Status = @Status
                    WHERE SimulationID = @SimulationID;", conn))
                {
                    cmd.Parameters.AddWithValue("@SimulationID", simulationId);
                    cmd.Parameters.AddWithValue("@Description",
                        string.IsNullOrWhiteSpace(txtDesc.Text) ? (object)DBNull.Value : txtDesc.Text.Trim());
                    cmd.Parameters.AddWithValue("@Status",
                        string.IsNullOrWhiteSpace(ddlStatus.SelectedValue) ? (object)DBNull.Value : ddlStatus.SelectedValue);

                    conn.Open();
                    int rows = cmd.ExecuteNonQuery();

                    if (rows > 0)
                    {
                        lblPill.Text = ddlStatus.SelectedValue;
                        lblMsg.Text = "Changes saved successfully.";
                        lblMsg.CssClass = "text-success"; // Fixed to use global CSS
                        lblMsg.Visible = true;
                    }
                    else
                    {
                        lblMsg.Text = "No simulation updated.";
                        lblMsg.CssClass = "text-error"; // Fixed to use global CSS
                        lblMsg.Visible = true;
                    }
                }
            }
            catch (Exception ex)
            {
                lblMsg.Text = "Save failed: " + ex.Message;
                lblMsg.CssClass = "text-error";
                lblMsg.Visible = true;
            }
        }

        protected void btnSave1_Click(object sender, EventArgs e)
        {
            SaveSimulationCard(1, txtDesc1, ddlStatus1, lblPill1, lblMsg1);
        }

        protected void btnSave2_Click(object sender, EventArgs e)
        {
            SaveSimulationCard(2, txtDesc2, ddlStatus2, lblPill2, lblMsg2);
        }

        protected void btnSave3_Click(object sender, EventArgs e)
        {
            SaveSimulationCard(3, txtDesc3, ddlStatus3, lblPill3, lblMsg3);
        }
    }
}