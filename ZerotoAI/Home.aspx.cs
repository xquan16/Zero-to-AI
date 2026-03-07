using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.NetworkInformation;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;
using Newtonsoft.Json;

namespace ZerotoAI
{
    public partial class Home : System.Web.UI.Page
    {
        // Reads the JSON file and populates all Labels and TextBoxes.
        private void LoadPageContent()
        {
            string filePath = Server.MapPath("~/App_Data/HomePage.json");

            if (File.Exists(filePath))
            {
                string json = File.ReadAllText(filePath);

                // Convert the JSON string back into a C# Dictionary
                var content = JsonConvert.DeserializeObject<Dictionary<string, string>>(json);

                if (content != null)
                {
                    // Hero Section
                    lblHeroTitle.Text = txtHeroTitle.Text = content.ContainsKey("HeroTitle") ? content["HeroTitle"] : "";
                    lblHeroSubtitle.Text = txtHeroSubtitle.Text = content.ContainsKey("HeroSubtitle") ? content["HeroSubtitle"] : "";
                    lblCtaText.Text = txtCtaText.Text = content.ContainsKey("CtaText") ? content["CtaText"] : "Get Started Now";

                    // About Section
                    lblAboutTitle.Text = txtAboutTitle.Text = content.ContainsKey("AboutTitle") ? content["AboutTitle"] : "";
                    lblAboutText.Text = txtAboutText.Text = content.ContainsKey("AboutText") ? content["AboutText"] : "";

                    // Features Grid
                    lblFeat1Title.Text = txtFeat1Title.Text = content.ContainsKey("Feature1Title") ? content["Feature1Title"] : "";
                    lblFeat1Desc.Text = txtFeat1Desc.Text = content.ContainsKey("Feature1Desc") ? content["Feature1Desc"] : "";

                    lblFeat2Title.Text = txtFeat2Title.Text = content.ContainsKey("Feature2Title") ? content["Feature2Title"] : "";
                    lblFeat2Desc.Text = txtFeat2Desc.Text = content.ContainsKey("Feature2Desc") ? content["Feature2Desc"] : "";

                    lblFeat3Title.Text = txtFeat3Title.Text = content.ContainsKey("Feature3Title") ? content["Feature3Title"] : "";
                    lblFeat3Desc.Text = txtFeat3Desc.Text = content.ContainsKey("Feature3Desc") ? content["Feature3Desc"] : "";

                    // Stats Row
                    lblStat1Num.Text = txtStat1Num.Text = content.ContainsKey("Stat1Num") ? content["Stat1Num"] : "";
                    lblStat1Text.Text = txtStat1Text.Text = content.ContainsKey("Stat1Label") ? content["Stat1Label"] : "";

                    lblStat2Num.Text = txtStat2Num.Text = content.ContainsKey("Stat2Num") ? content["Stat2Num"] : "";
                    lblStat2Text.Text = txtStat2Text.Text = content.ContainsKey("Stat2Label") ? content["Stat2Label"] : "";

                    lblStat3Num.Text = txtStat3Num.Text = content.ContainsKey("Stat3Num") ? content["Stat3Num"] : "";
                    lblStat3Text.Text = txtStat3Text.Text = content.ContainsKey("Stat3Label") ? content["Stat3Label"] : "";
                }
            }
        }


        /// Grabs the text from the TextBoxes, packs it into JSON, and overwrites the file.
        private void SavePageContent()
        {
            var content = new Dictionary<string, string>
            {
                { "HeroTitle", txtHeroTitle.Text },
                { "HeroSubtitle", txtHeroSubtitle.Text },
                { "CtaText", txtCtaText.Text },

                { "AboutTitle", txtAboutTitle.Text },
                { "AboutText", txtAboutText.Text },

                { "Feature1Title", txtFeat1Title.Text },
                { "Feature1Desc", txtFeat1Desc.Text },
                { "Feature2Title", txtFeat2Title.Text },
                { "Feature2Desc", txtFeat2Desc.Text },
                { "Feature3Title", txtFeat3Title.Text },
                { "Feature3Desc", txtFeat3Desc.Text },

                { "Stat1Num", txtStat1Num.Text },
                { "Stat1Label", txtStat1Text.Text },
                { "Stat2Num", txtStat2Num.Text },
                { "Stat2Label", txtStat2Text.Text },
                { "Stat3Num", txtStat3Num.Text },
                { "Stat3Label", txtStat3Text.Text }
            };

            // Convert C# Dictionary back to a formatted JSON string
            string json = JsonConvert.SerializeObject(content, Formatting.Indented);

            // Overwrite the file
            string filePath = Server.MapPath("~/App_Data/HomePage.json");
            File.WriteAllText(filePath, json);
        }


        /// Flips the visibility of Labels (View Mode) and TextBoxes (Edit Mode)    
        private void ToggleEditMode(bool isEdit)
        {
            // Toggle Buttons
            btnEditMode.Visible = !isEdit;
            btnCancel.Visible = isEdit;
            btnSaveChanges.Visible = isEdit;

            // Toggle Hero
            lblHeroTitle.Visible = !isEdit; txtHeroTitle.Visible = isEdit;
            lblHeroSubtitle.Visible = !isEdit; txtHeroSubtitle.Visible = isEdit;

            // Toggle About
            lblAboutTitle.Visible = !isEdit; txtAboutTitle.Visible = isEdit;
            lblAboutText.Visible = !isEdit; txtAboutText.Visible = isEdit;

            // Toggle Features
            lblFeat1Title.Visible = !isEdit; txtFeat1Title.Visible = isEdit;
            lblFeat1Desc.Visible = !isEdit; txtFeat1Desc.Visible = isEdit;

            lblFeat2Title.Visible = !isEdit; txtFeat2Title.Visible = isEdit;
            lblFeat2Desc.Visible = !isEdit; txtFeat2Desc.Visible = isEdit;

            lblFeat3Title.Visible = !isEdit; txtFeat3Title.Visible = isEdit;
            lblFeat3Desc.Visible = !isEdit; txtFeat3Desc.Visible = isEdit;

            // Toggle Stats
            lblStat1Num.Visible = !isEdit; txtStat1Num.Visible = isEdit;
            lblStat1Text.Visible = !isEdit; txtStat1Text.Visible = isEdit;

            lblStat2Num.Visible = !isEdit; txtStat2Num.Visible = isEdit;
            lblStat2Text.Visible = !isEdit; txtStat2Text.Visible = isEdit;

            lblStat3Num.Visible = !isEdit; txtStat3Num.Visible = isEdit;
            lblStat3Text.Visible = !isEdit; txtStat3Text.Visible = isEdit;

            // Toggle CTA Button
            btnHeroCTA.Visible = !isEdit;
            txtCtaText.Visible = isEdit;

            // Disable the CTA button
            if (isEdit)
            {
                btnHeroCTA.Attributes["class"] = "cta-button disabled-btn";
                btnHeroCTA.Attributes["onclick"] = "return false;"; // Truly blocks the click
            }
            else
            {
                btnHeroCTA.Attributes["class"] = "cta-button";
                btnHeroCTA.Attributes.Remove("onclick");
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadPageContent();

                // Role-based visibility logic
                if (Session["UserRole"] != null)
                {
                    string role = Session["UserRole"].ToString();

                    if (role == "Admin")
                    {
                        pnlAdminBar.Visible = true; // Show edit tools for Admin
                    }
                    else if (role == "Member" || role == "Editor")
                    {
                        btnHeroCTA.Visible = false; // Hide the CTA button for logged-in users
                    }
                }
            }
        }

        protected void btnEditMode_Click(object sender, EventArgs e)
        {
            ToggleEditMode(true); // Turn ON Edit Mode
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            ToggleEditMode(false); // Turn OFF Edit Mode
            LoadPageContent();     // Reset any unsaved typing back to what is in the JSON file
        }

        protected void btnSaveChanges_Click(object sender, EventArgs e)
        {
            SavePageContent();     // Write the textboxes to the JSON file
            LoadPageContent();     // Refresh the Labels with the newly saved data
            ToggleEditMode(false); // Turn OFF Edit Mode
        }
    }
}