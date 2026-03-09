<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AdminCourses.aspx.cs" Inherits="Zero_to_AI.Admin.AdminCourses" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <asp:MultiView ID="MainMultiView" runat="server" ActiveViewIndex="0">

        <!-- ════════════════ VIEW 0: DASHBOARD ════════════════ -->
        <asp:View ID="ViewDashboard" runat="server">

            <div class="admin-hero">
                <h1><i class="fas fa-chart-bar" style="margin-right:10px"></i>Course Administration</h1>
                <p>Monitor learning materials status and student enrollment statistics across all modules.</p>
            </div>

            <asp:Label ID="lblMessage" runat="server" Visible="false" CssClass="alert-box alert-success"></asp:Label>

            <!-- Summary stats pulled from DB -->
            <div class="summary-row">
                <div class="sum-card">
                    <div class="sum-icon blue"><i class="fas fa-book-open"></i></div>
                    <div class="sum-info">
                        <h3><asp:Label ID="lblTotalArticles" runat="server">0</asp:Label></h3>
                        <span>Total Articles</span>
                    </div>
                </div>
                <div class="sum-card">
                    <div class="sum-icon green"><i class="fas fa-check-circle"></i></div>
                    <div class="sum-info">
                        <h3><asp:Label ID="lblPublished" runat="server">0</asp:Label></h3>
                        <span>Published</span>
                    </div>
                </div>
                <div class="sum-card">
                    <div class="sum-icon orange"><i class="fas fa-user-graduate"></i></div>
                    <div class="sum-info">
                        <h3><asp:Label ID="lblTotalCompletions" runat="server">0</asp:Label></h3>
                        <span>Total Completions</span>
                    </div>
                </div>
                <div class="sum-card">
                    <div class="sum-icon red"><i class="fas fa-users"></i></div>
                    <div class="sum-info">
                        <h3><asp:Label ID="lblTotalMembers" runat="server">0</asp:Label></h3>
                        <span>Registered Members</span>
                    </div>
                </div>
            </div>

            <!-- Filter tabs -->
            <div class="filter-tabs">
                <button class="filter-tab active" data-filter="all"    onclick="filterSec('all',this)">All</button>
                <button class="filter-tab"         data-filter="ml"    onclick="filterSec('ml',this)"><i class="fas fa-brain"></i> Machine Learning</button>
                <button class="filter-tab"         data-filter="robot" onclick="filterSec('robot',this)"><i class="fas fa-microchip"></i> Robotics</button>
            </div>

            <!-- Machine Learning -->
            <div id="sec-ml" class="mb-4">
                <div class="sec-header">
                    <div class="sec-icon ml"><i class="fas fa-brain"></i></div>
                    <h3>Machine Learning</h3>
                    <div class="sec-divider"></div>
                </div>
                <div class="row g-3">
                    <asp:Repeater ID="rptML" runat="server" OnItemCommand="rptCourses_ItemCommand">
                        <ItemTemplate>
                            <div class="col-12 col-sm-6 col-lg-3">
                                <div class="course-card">
                                    <span class='status-badge <%# GetBadgeClass(Eval("Status")) %>'><%# Eval("Status") %></span>
                                    <div class="card-banner banner-ml">
                                        <i class="fas <%# Eval("ImageURL") %>"></i>
                                    </div>
                                    <div class="card-body">
                                        <div class="card-title"><%# Eval("Title") %></div>
                                        <div class="mini-stats">
                                            <div class="mini-stat">
                                                <span class="val"><%# Eval("Views") %></span>
                                                <span class="lbl">Views</span>
                                            </div>
                                            <div class="mini-stat">
                                                <span class="val"><%# Eval("Completions") %></span>
                                                <span class="lbl">Done</span>
                                            </div>
                                            <div class="mini-stat">
                                                <span class="val"><%# Eval("QuestionCount") %></span>
                                                <span class="lbl">Qs</span>
                                            </div>
                                        </div>
                                        <div class="prog-wrap">
                                            <div class="prog-label">
                                                <span>Completion Rate</span>
                                                <span><%# Eval("CompletionRate") %>%</span>
                                            </div>
                                            <div class="prog-bar">
                                                <div class="prog-fill" style="width:<%# Eval("CompletionRate") %>%"></div>
                                            </div>
                                        </div>
                                        <asp:LinkButton runat="server" CommandName="ViewArticle" CommandArgument='<%# Eval("ArticleID") %>' CssClass="btn-view">
                                            <i class="fas fa-chart-bar"></i> View Analytics
                                        </asp:LinkButton>
                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>

            <!-- Robotics -->
            <div id="sec-robot">
                <div class="sec-header">
                    <div class="sec-icon robot"><i class="fas fa-microchip"></i></div>
                    <h3>Robotics</h3>
                    <div class="sec-divider"></div>
                </div>
                <div class="row g-3">
                    <asp:Repeater ID="rptRobot" runat="server" OnItemCommand="rptCourses_ItemCommand">
                        <ItemTemplate>
                            <div class="col-12 col-sm-6 col-lg-3">
                                <div class="course-card">
                                    <span class='status-badge <%# GetBadgeClass(Eval("Status")) %>'><%# Eval("Status") %></span>
                                    <div class="card-banner banner-robot">
                                        <i class="fas <%# Eval("ImageURL") %>"></i>
                                    </div>
                                    <div class="card-body">
                                        <div class="card-title"><%# Eval("Title") %></div>
                                        <div class="mini-stats">
                                            <div class="mini-stat">
                                                <span class="val"><%# Eval("Views") %></span>
                                                <span class="lbl">Views</span>
                                            </div>
                                            <div class="mini-stat">
                                                <span class="val"><%# Eval("Completions") %></span>
                                                <span class="lbl">Done</span>
                                            </div>
                                            <div class="mini-stat">
                                                <span class="val"><%# Eval("QuestionCount") %></span>
                                                <span class="lbl">Qs</span>
                                            </div>
                                        </div>
                                        <div class="prog-wrap">
                                            <div class="prog-label">
                                                <span>Completion Rate</span>
                                                <span><%# Eval("CompletionRate") %>%</span>
                                            </div>
                                            <div class="prog-bar">
                                                <div class="prog-fill" style="width:<%# Eval("CompletionRate") %>%"></div>
                                            </div>
                                        </div>
                                        <asp:LinkButton runat="server" CommandName="ViewArticle" CommandArgument='<%# Eval("ArticleID") %>' CssClass="btn-view">
                                            <i class="fas fa-chart-bar"></i> View Analytics
                                        </asp:LinkButton>
                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>

        </asp:View>

        <!-- ════════════════ VIEW 1: ARTICLE ANALYTICS ════════════════ -->
        <asp:View ID="ViewAnalytics" runat="server">

            <asp:LinkButton ID="btnBack" runat="server" OnClick="btnBack_Click" CssClass="btn-back">
                <i class="fas fa-arrow-left"></i> Back to Dashboard
            </asp:LinkButton>

            <div class="analytics-panel">

                <h2>
                    <i class="fas fa-chart-bar"></i>
                    <asp:Label ID="lblAnalyticsTitle" runat="server"></asp:Label>
                </h2>

                <!-- 3 stat cards -->
                <div class="stat-grid">
                    <div class="stat-card blue">
                        <h3><asp:Label ID="lblTotalViews" runat="server">0</asp:Label></h3>
                        <span><i class="fas fa-eye"></i> Total Views</span>
                    </div>
                    <div class="stat-card green">
                        <h3><asp:Label ID="lblStudentCompletions" runat="server">0</asp:Label></h3>
                        <span><i class="fas fa-user-graduate"></i> Students Completed</span>
                    </div>
                    <div class="stat-card orange">
                        <h3><asp:Label ID="lblCompletionRate" runat="server">0</asp:Label>%</h3>
                        <span><i class="fas fa-trophy"></i> Completion Rate</span>
                    </div>
                </div>

                <!-- Article details -->
                <div style="margin-bottom:24px; padding:16px; background:var(--bg-card,#f8f9fa); border-radius:10px; border:1px solid var(--border-color);">
                    <div class="row">
                        <div class="col-md-4">
                            <small style="color:var(--text-muted); font-weight:600; text-transform:uppercase;">Category</small>
                            <p style="margin:2px 0 0; font-weight:700; color:var(--text-main);"><asp:Label ID="lblCategory" runat="server"></asp:Label></p>
                        </div>
                        <div class="col-md-4">
                            <small style="color:var(--text-muted); font-weight:600; text-transform:uppercase;">Status</small>
                            <p style="margin:2px 0 0;"><asp:Label ID="lblStatus" runat="server"></asp:Label></p>
                        </div>
                        <div class="col-md-4">
                            <small style="color:var(--text-muted); font-weight:600; text-transform:uppercase;">Quiz Questions</small>
                            <p style="margin:2px 0 0; font-weight:700; color:var(--text-main);"><asp:Label ID="lblQCount" runat="server">0</asp:Label> questions</p>
                        </div>
                    </div>
                </div>

                <!-- Who completed this module -->
                <h4 style="font-size:1rem; font-weight:700; margin-bottom:14px;">
                    <i class="fas fa-users" style="margin-right:6px; color:var(--bg-sidebar)"></i>
                    Students Who Completed This Module
                </h4>

                <asp:Literal ID="litCompletions" runat="server"></asp:Literal>

            </div>

        </asp:View>

    </asp:MultiView>

    <script>
        function filterSec(cat, btn) {
            localStorage.setItem('adminCourseFilter', cat);
            var ml = document.getElementById('sec-ml');
            var robot = document.getElementById('sec-robot');
            if (ml) ml.style.display = (cat === 'robot') ? 'none' : 'block';
            if (robot) robot.style.display = (cat === 'ml') ? 'none' : 'block';
            document.querySelectorAll('.filter-tab').forEach(function (b) { b.classList.remove('active'); });
            btn.classList.add('active');
        }

        window.addEventListener('DOMContentLoaded', function () {
            var saved = localStorage.getItem('adminCourseFilter') || 'all';
            var ml = document.getElementById('sec-ml');
            var robot = document.getElementById('sec-robot');
            if (ml) ml.style.display = (saved === 'robot') ? 'none' : 'block';
            if (robot) robot.style.display = (saved === 'ml') ? 'none' : 'block';
            document.querySelectorAll('.filter-tab').forEach(function (b) {
                b.classList.remove('active');
                if (b.getAttribute('data-filter') === saved) b.classList.add('active');
            });
        });
    </script>

</asp:Content>

