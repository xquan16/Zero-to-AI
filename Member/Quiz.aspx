<%@ Page Title="Quiz Challenge" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Quiz.aspx.cs" Inherits="Zero_to_AI.Member.Quiz" Async="true" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    
<script>
    var timerInterval;
    var timeLeft = 600;

    function startTimer() {
        var display = document.getElementById('timerDisplay');
        if (!display) return;
        timerInterval = setInterval(function () {
            var m = Math.floor(timeLeft / 60);
            var s = timeLeft % 60;
            if (s < 10) s = "0" + s;
            if (m < 10) m = "0" + m;
            if (display) display.innerText = m + ":" + s;

            if (timeLeft <= 0) {
                stopTimer();
                alert("Time's up!");
                var btn = document.getElementById('<%= btnSubmit.ClientID %>');
                    if (btn) btn.click();
                }
                timeLeft--;
            }, 1000);
    }

    function stopTimer() {
        if (timerInterval) clearInterval(timerInterval);
    }

    window.onload = startTimer;

    function scrollChatToBottom() {
        var chat = document.getElementById('chatHistory');
        if (chat) chat.scrollTop = chat.scrollHeight;
    }
</script>

    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>

    <asp:UpdatePanel ID="upMain" runat="server">
        <ContentTemplate>
            <div id="mainWrapper" runat="server" class="main-wrapper mode-center">
                
                <div class="quiz-container-left">
                    <div class="quiz-header-bar">
                        <h2 class="dynamic-title">
                            <asp:Label ID="lblTitle" runat="server" Text="Loading Quiz..."></asp:Label>
                        </h2>
                        <div id="timerContainer" runat="server" class="timer-badge">
                            ⏳ <span id="timerDisplay">10:00</span>
                        </div>
                    </div>

                    <asp:Repeater ID="rptQuestions" runat="server" OnItemCommand="rptQuestions_ItemCommand" OnItemDataBound="rptQuestions_ItemDataBound">
                        <ItemTemplate>
                            <div class="question-block">
                                <span class="marks-label"><%# Eval("Marks") %> pts</span>
                                
                                <div class="q-text">
                                    <%# Container.ItemIndex + 1 %>. <asp:Label ID="lblQText" runat="server" Text='<%# Eval("QuestionText") %>'></asp:Label>
                                </div>
                                
                                <asp:HiddenField ID="hfQuestionID" runat="server" Value='<%# Eval("QuestionID") %>' />
                                <asp:HiddenField ID="hfCorrectAns" runat="server" Value='<%# Eval("CorrectAnswer") %>' />

                                <div class="options-box">
                                    <asp:Panel ID="pnlA" runat="server"><label><asp:RadioButton ID="rbA" runat="server" GroupName='<%# "Q"+Eval("QuestionID") %>' /> A. <asp:Label ID="lblA" runat="server" Text='<%# Eval("OptionA") %>'></asp:Label></label></asp:Panel>
                                    <asp:Panel ID="pnlB" runat="server"><label><asp:RadioButton ID="rbB" runat="server" GroupName='<%# "Q"+Eval("QuestionID") %>' /> B. <asp:Label ID="lblB" runat="server" Text='<%# Eval("OptionB") %>'></asp:Label></label></asp:Panel>
                                    <asp:Panel ID="pnlC" runat="server"><label><asp:RadioButton ID="rbC" runat="server" GroupName='<%# "Q"+Eval("QuestionID") %>' /> C. <asp:Label ID="lblC" runat="server" Text='<%# Eval("OptionC") %>'></asp:Label></label></asp:Panel>
                                    <asp:Panel ID="pnlD" runat="server"><label><asp:RadioButton ID="rbD" runat="server" GroupName='<%# "Q"+Eval("QuestionID") %>' /> D. <asp:Label ID="lblD" runat="server" Text='<%# Eval("OptionD") %>'></asp:Label></label></asp:Panel>
                                </div>

                                <asp:Button ID="btnExplain" runat="server" Text="💡 Ask AI to Explain" CommandName="Explain" CommandArgument='<%# Container.ItemIndex %>' CssClass="btn-explain" Visible="false" />
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>

                    <div style="margin-top: 30px; text-align: center;">
                        <asp:Button ID="btnSubmit" runat="server" Text="Submit Answers" CssClass="btn-submit" OnClick="btnSubmit_Click" style="padding:15px 40px; background:#3498db; color:#fff; border:none; border-radius:8px; font-weight:bold; cursor:pointer; font-size:16px; transition:0.3s;" />
                        
                        <div class="result-area" style="margin-top:20px;">
                            <asp:Label ID="lblResult" runat="server" Font-Bold="true" Font-Size="X-Large" Visible="false"></asp:Label>
                            <br /><br />
                            <asp:Button ID="btnBack" runat="server" Text="Back to Topics" CssClass="btn-back" OnClick="btnBack_Click" Visible="false" style="padding:10px 30px; background:#95a5a6; color:#fff; border:none; border-radius:8px; cursor:pointer; font-weight:bold;" />
                        </div>
                    </div>
                </div>

                <div id="aiChatPanel" runat="server" class="ai-chat-right" visible="false">
                    <div class="chat-header">✨ AI Tutor Chat</div>
                    
                    <div id="chatHistory" class="chat-messages">
                        <asp:Literal ID="litChatHistory" runat="server">
                            <div class="msg-bubble msg-ai">Hi! I am your AI Tutor. Click "💡 Ask AI to Explain" on any question!</div>
                        </asp:Literal>
                    </div>

                    <div class="chat-input-area">
                        <asp:TextBox ID="txtChatInput" runat="server" CssClass="chat-input" placeholder="Ask follow-up questions..."></asp:TextBox>
                        <asp:Button ID="btnSendChat" runat="server" Text="Send" CssClass="btn-send" OnClick="btnSendChat_Click" OnClientClick="setTimeout(scrollChatToBottom, 500);" />
                    </div>
                </div>
                
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>

</asp:Content>

