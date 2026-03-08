<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="MemberQuiz.aspx.cs" Inherits="Zero_to_AI.Member.MemberQuiz" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    
   
    <script>
        var timeLeft = 600; // 10 mins
        function startTimer() {
            var display = document.getElementById('timerDisplay');
            // if cant find timerDisplay means that invisible by the backend then stop the timer
            if (!display) return;

            var interval = setInterval(function () {
                var m = Math.floor(timeLeft / 60);
                var s = timeLeft % 60;
                if (s < 10) s = "0" + s;
                if (m < 10) m = "0" + m;

                if (display) display.innerText = m + ":" + s;

                if (timeLeft <= 0) {
                    clearInterval(interval);
                    alert("Time's up!");
                    var btn = document.getElementById('<%= btnSubmit.ClientID %>');
                    if (btn) btn.click();
                }
                timeLeft--;
            }, 1000);
        }
        window.onload = startTimer;
    </script>

    <div class="quiz-container">
        
        <div class="quiz-header-bar">
            <h2 class="dynamic-title">
                <asp:Label ID="lblTitle" runat="server" Text="Loading Quiz..."></asp:Label>
            </h2>
            
            <div id="timerContainer" runat="server" class="timer-badge">
                ⏳ <span id="timerDisplay">10:00</span>
            </div>
        </div>

        <asp:Repeater ID="rptQuestions" runat="server">
            <ItemTemplate>
                <div class="question-block">
                    <span class="marks-label"><%# Eval("Marks") %> pts</span>
                    <div class="q-text"><%# Container.ItemIndex + 1 %>. <%# Eval("QuestionText") %></div>
                    <asp:HiddenField ID="hfQuestionID" runat="server" Value='<%# Eval("QuestionID") %>' />
                    <div class="options-box">
                        <label><asp:RadioButton ID="rbA" runat="server" GroupName='<%# "Q"+Eval("QuestionID") %>' /> A. <%# Eval("OptionA") %></label>
                        <label><asp:RadioButton ID="rbB" runat="server" GroupName='<%# "Q"+Eval("QuestionID") %>' /> B. <%# Eval("OptionB") %></label>
                        <label><asp:RadioButton ID="rbC" runat="server" GroupName='<%# "Q"+Eval("QuestionID") %>' /> C. <%# Eval("OptionC") %></label>
                        <label><asp:RadioButton ID="rbD" runat="server" GroupName='<%# "Q"+Eval("QuestionID") %>' /> D. <%# Eval("OptionD") %></label>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>

        <asp:Button ID="btnSubmit" runat="server" Text="Submit Answers" CssClass="btn-submit" OnClick="btnSubmit_Click" />
        
        <div class="result-area">
            <asp:Label ID="lblResult" runat="server" Font-Bold="true" Font-Size="X-Large" Visible="false"></asp:Label>
            <br />
            <asp:Button ID="btnBack" runat="server" Text="Back to Topics" CssClass="btn-back" OnClick="btnBack_Click" Visible="false" />
        </div>
    </div>

</asp:Content>

