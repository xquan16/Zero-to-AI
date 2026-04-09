using System;
using System.Collections.Generic;
using System.Configuration;
using System.Net.Http;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;

namespace Zero_to_AI.ZerotoAI
{
    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [System.ComponentModel.ToolboxItem(false)]
    [System.Web.Script.Services.ScriptService]
    public class ChatService : System.Web.Services.WebService
    {
        public class ChatMessage
        {
            public string Role { get; set; }
            public string Text { get; set; }
        }

        // THE MEMORY ENDPOINT
        [WebMethod(EnableSession = true)]
        public List<ChatMessage> GetChatHistory()
        {
            List<ChatMessage> history = Session["ChatHistory"] as List<ChatMessage>;
            return history ?? new List<ChatMessage>();
        }

        // THE CHAT ENDPOINT
        [WebMethod(EnableSession = true)]
        public string SendMessage(string userMessage)
        {
            if (string.IsNullOrWhiteSpace(userMessage)) return "";

            try
            {
                List<ChatMessage> history = Session["ChatHistory"] as List<ChatMessage>;
                if (history == null) history = new List<ChatMessage>();

                history.Add(new ChatMessage { Role = "user", Text = userMessage.Trim() });

                if (history.Count > 10) history.RemoveRange(0, 2);

                var js = new JavaScriptSerializer();
                var contentsList = new List<object>();

                foreach (var msg in history)
                {
                    if (!string.IsNullOrWhiteSpace(msg.Text))
                    {
                        contentsList.Add(new { role = msg.Role, parts = new[] { new { text = msg.Text } } });
                    }
                }

                var requestBody = new
                {
                    systemInstruction = new
                    {
                        parts = new[] { new { text = @"You are Zoa, the friendly and brilliant AI tutor for the 'Zero to AI' platform. 
You help students learn Artificial Intelligence concepts. Keep your answers brief, highly readable, and use emojis. 

You also act as the official site navigator. You know the exact layout of the website. Use these rules to guide users:
- DASHBOARD: If a user asks to report a bug, send feedback, or request a topic, tell them to click 'Dashboard' in the left sidebar and use the 'Send Feedback' box.
- LEFT SIDEBAR: Contains the main navigation. If a user asks to learn, tell them to click 'Courses'. If they want to practice, tell them to click 'Simulations'. If they want to take a test, tell them to click 'Quizzes'. (Note: The sidebar can be toggled using the top-left hamburger menu icon).
- EDIT / UPDATE PROFILE: If a user asks how to edit their profile, update their details (like name or email), change their password, or generate an AI Avatar, tell them to click their circular profile picture in the top-right corner and select 'Edit Profile'.
- DARK MODE: If a user asks how to change the website colors or turn on dark mode, tell them to click the Moon/Sun icon in the top right navigation bar.
- QUIZZES: If they ask how to do a quiz specifically, tell them: 'Just click the Quizzes tab in the left sidebar, pick a topic you want to test your knowledge on, and hit Start!'" } }
                    },
                    contents = contentsList
                };

                string jsonBody = js.Serialize(requestBody);
                string apiKey = ConfigurationManager.AppSettings["ZoaApiKey"];
                string apiUrl = $"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key={apiKey}";

                string aiText = System.Threading.Tasks.Task.Run(async () =>
                {
                    using (HttpClient client = new HttpClient())
                    {
                        var content = new StringContent(jsonBody, Encoding.UTF8, "application/json");
                        HttpResponseMessage response = await client.PostAsync(apiUrl, content);

                        string jsonResponse = await response.Content.ReadAsStringAsync();

                        if (!response.IsSuccessStatusCode)
                            return "ZOA_ERROR: API Error: " + response.StatusCode;

                        dynamic result = js.Deserialize<dynamic>(jsonResponse);
                        return (string)result["candidates"][0]["content"]["parts"][0]["text"];
                    }
                }).GetAwaiter().GetResult();

                if (!aiText.StartsWith("ZOA_ERROR"))
                {
                    history.Add(new ChatMessage { Role = "model", Text = aiText });
                    Session["ChatHistory"] = history;
                }

                return aiText;
            }
            catch (Exception ex)
            {
                return "ZOA_ERROR: " + ex.Message;
            }
        }
    }
}