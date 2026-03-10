<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Courses.aspx.cs" Inherits="Zero_to_AI.Member.Courses" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>



<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

<asp:MultiView ID="MainView" runat="server" ActiveViewIndex="0">
        <asp:View ID="ViewCatalogue" runat="server">

            <div class="courses-hero">
                <h1><i class="fas fa-graduation-cap" style="margin-right:10px"></i>My Learning</h1>
                <p>Choose a module, read the lesson, then test yourself with a quiz.</p>
            </div>

            <asp:Label ID="lblAlert" runat="server" CssClass="alert-msg" Visible="false"></asp:Label>

            <div class="filter-tabs">
                <button type="button" class="filter-tab active" data-filter="all" onclick="filterSection('all',this)"><i class="fas fa-th"></i> All</button>
                <button type="button" class="filter-tab" data-filter="ml" onclick="filterSection('ml',this)"><i class="fas fa-brain"></i> Machine Learning</button>
                <button type="button" class="filter-tab" data-filter="robot" onclick="filterSection('robot',this)"><i class="fas fa-microchip"></i> Robotics</button>
            </div>

            <div id="sec-ml">
                <div class="section-header">
                    <div class="section-icon icon-ml"><i class="fas fa-brain"></i></div>
                    <div>
                        <h3>Machine Learning</h3>
                        <p><asp:Label ID="lblMLCount" runat="server">0 modules</asp:Label> · From AI basics to Python tools</p>
                    </div>
                    <div class="section-divider"></div>
                </div>
                
                <div class="courses-grid mb-4">
                    <asp:Repeater ID="rptML" runat="server" OnItemCommand="rptCourses_ItemCommand">
                        <ItemTemplate>
                            <div class="course-card">
                                <div class="card-banner banner-ml">
                                    <i class="fas <%# Eval("ImageURL") %>"></i>
                                    <%# IsCompleted(Eval("IsCompleted")) ? "<div class='done-badge'><i class='fas fa-check'></i> Done</div>" : "" %>
                                </div>
                                <div class="card-body">
                                    <div class="card-tag">Machine Learning</div>
                                    <div class="card-title"><%# Eval("Title") %></div>
                                    <div class="card-desc"><%# Eval("Description") %></div>
                                    <div class="progress-wrap">
                                        <div class="progress-label">
                                            <span>Progress</span>
                                            <span><%# IsCompleted(Eval("IsCompleted")) ? "100%" : "0%" %></span>
                                        </div>
                                        <div class="progress-bar-bg">
                                            <div class="progress-fill" style='<%# "width:" + (IsCompleted(Eval("IsCompleted")) ? "100%" : "0%") %>'></div>
                                        </div>
                                    </div>
                                    <asp:LinkButton runat="server"
                                        CommandName="OpenCourse"
                                        CommandArgument='<%# Eval("ArticleID") %>'
                                        CssClass='<%# "btn-start" + (IsCompleted(Eval("IsCompleted")) ? " done" : "") %>'>
                                        <%# IsCompleted(Eval("IsCompleted")) ? "<i class='fas fa-check-circle'></i> Review" : "<i class='fas fa-play-circle'></i> Start Learning" %>
                                    </asp:LinkButton>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>

            <div id="sec-robot">
                <div class="section-header">
                    <div class="section-icon icon-robot"><i class="fas fa-microchip"></i></div>
                    <div>
                        <h3>Robotics</h3>
                        <p><asp:Label ID="lblRobotCount" runat="server">0 modules</asp:Label> · From sensors to building your first robot</p>
                    </div>
                    <div class="section-divider"></div>
                </div>
                
                <div class="courses-grid">
                    <asp:Repeater ID="rptRobot" runat="server" OnItemCommand="rptCourses_ItemCommand">
                        <ItemTemplate>
                            <div class="course-card">
                                <div class="card-banner banner-robot">
                                    <i class="fas <%# Eval("ImageURL") %>"></i>
                                    <%# IsCompleted(Eval("IsCompleted")) ? "<div class='done-badge'><i class='fas fa-check'></i> Done</div>" : "" %>
                                </div>
                                <div class="card-body">
                                    <div class="card-tag">Robotics</div>
                                    <div class="card-title"><%# Eval("Title") %></div>
                                    <div class="card-desc"><%# Eval("Description") %></div>
                                    <div class="progress-wrap">
                                        <div class="progress-label">
                                            <span>Progress</span>
                                            <span><%# IsCompleted(Eval("IsCompleted")) ? "100%" : "0%" %></span>
                                        </div>
                                        <div class="progress-bar-bg">
                                            <div class="progress-fill" style='<%# "width:" + (IsCompleted(Eval("IsCompleted")) ? "100%" : "0%") %>'></div>
                                        </div>
                                    </div>
                                    <asp:LinkButton runat="server"
                                        CommandName="OpenCourse"
                                        CommandArgument='<%# Eval("ArticleID") %>'
                                        CssClass='<%# "btn-start" + (IsCompleted(Eval("IsCompleted")) ? " done" : "") %>'>
                                        <%# IsCompleted(Eval("IsCompleted")) ? "<i class='fas fa-check-circle'></i> Review" : "<i class='fas fa-play-circle'></i> Start Learning" %>
                                    </asp:LinkButton>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>
        </asp:View> 

        <asp:View ID="ViewRoom" runat="server">
            <div class="room-wrap">

                <div class="room-topbar">
                    <div class="breadcrumb-txt">
                        My Learning &rsaquo;
                        <asp:Label ID="lblBreadCat" runat="server"></asp:Label> &rsaquo;
                        <span><asp:Label ID="lblBreadTitle" runat="server"></asp:Label></span>
                    </div>
                    <asp:LinkButton ID="btnBack" runat="server" OnClick="btnBack_Click" CssClass="btn-back">
                        <i class="fas fa-arrow-left"></i> Back to Courses
                    </asp:LinkButton>
                </div>

                <div class="room-layout">

                    <div class="room-main">
                        <asp:Label ID="lblCatTag" runat="server"></asp:Label>
                        <h1 class="art-title"><asp:Label ID="lblTitle" runat="server"></asp:Label></h1>
                        <hr class="art-hr" />
                        <div class="content-area">
                            <asp:Literal ID="litContent" runat="server"></asp:Literal>
                        </div>

                        <div class="quiz-section">
                            <div class="quiz-header">
                                <i class="fas fa-question-circle"></i>
                                <h3>Knowledge Check</h3>
                            </div>
                            <asp:Literal ID="litQuiz" runat="server"></asp:Literal>
                        </div>
                    </div>

                    <div class="room-sidebar">

                        <div class="cta-card">
                            <h5><i class="fas fa-trophy" style="margin-right:6px"></i>Ready to level up?</h5>
                            <p>Finished reading? Mark this module complete.</p>
                            <asp:LinkButton ID="btnMarkComplete" runat="server" OnClick="btnMarkComplete_Click" CssClass="btn-complete">
                                <i class="fas fa-check-circle"></i> Mark as Completed
                            </asp:LinkButton>
                        </div>

                        <div class="sc-card">
                            <h5><i class="fas fa-check-double"></i> Key Takeaways</h5>
                            <asp:Literal ID="litTakeaways" runat="server"></asp:Literal>
                        </div>

                    </div>
                </div>
            </div>
    </asp:View>
</asp:MultiView>

    <script>
        function filterSection(cat, btn) {
            // 1. Save your choice so it remembers if you refresh
            localStorage.setItem('courseFilter', cat);

            // 2. Grab the two main sections by their ID
            var ml = document.getElementById('sec-ml');
            var robot = document.getElementById('sec-robot');

            // 3. Hide or show them based on what you clicked
            if (ml) ml.style.display = (cat === 'robot') ? 'none' : 'block';
            if (robot) robot.style.display = (cat === 'ml') ? 'none' : 'block';

            // 4. Move the blue highlight to the button you just clicked
            document.querySelectorAll('.filter-tab').forEach(function (b) { b.classList.remove('active'); });
            btn.classList.add('active');
        }

        window.addEventListener('DOMContentLoaded', function () {
            var saved = localStorage.getItem('courseFilter') || 'all';
            var ml = document.getElementById('sec-ml');
            var robot = document.getElementById('sec-robot');
            if (ml) ml.style.display = (saved === 'robot') ? 'none' : 'block';
            if (robot) robot.style.display = (saved === 'ml') ? 'none' : 'block';
            document.querySelectorAll('.filter-tab').forEach(function (b) {
                b.classList.remove('active');
                if (b.getAttribute('data-filter') === saved) b.classList.add('active');
            });
        });

        // btn receives the button element itself (onclick='checkAnswer(this)')
        // correct answer stored in data-correct attribute — no quoting issues
        function checkAnswer(btn) {
            var qid = btn.getAttribute('data-qid');
            var correct = btn.getAttribute('data-correct');
            var sel = document.querySelector('input[name="q' + qid + '"]:checked');
            var fb = document.getElementById('fb' + qid);
            if (!fb) return;
            if (!sel) {
                fb.className = 'q-feedback wrong';
                fb.innerHTML = '<i class="fas fa-exclamation-circle"></i> Please select an answer first.';
                return;
            }
            if (sel.value.toUpperCase() === correct.toUpperCase()) {
                fb.className = 'q-feedback correct';
                fb.innerHTML = '<i class="fas fa-check-circle"></i> Correct! Well done.';
            } else {
                // Find label text of the correct option for a helpful hint
                var correctInput = document.querySelector('input[name="q' + qid + '"][value="' + correct + '"]');
                var hint = correctInput ? correctInput.parentElement.textContent.trim() : correct;
                fb.className = 'q-feedback wrong';
                fb.innerHTML = '<i class="fas fa-times-circle"></i> Not quite. Correct answer: <strong>' + hint + '</strong>';
            }
        }
    </script>
</asp:Content>
