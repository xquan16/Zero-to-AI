<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Simulations.aspx.cs" Inherits="Zero_to_AI.Member.Simulations" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <asp:ScriptManager ID="ScriptManager1" runat="server" />
    
    <asp:UpdatePanel ID="upHiddenLog" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <asp:HiddenField ID="hfSimId" runat="server" />
            
            <asp:Button ID="btnHiddenLog" runat="server" OnClick="btnHiddenLog_Click" style="visibility:hidden; position:absolute;" />
            
            <div style="text-align:center; margin-top: 10px;">
                <asp:Label ID="lblSimDebug" runat="server" Font-Bold="true"></asp:Label>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>

    <div class="sim-page">
        <div class="sim-hero">
            <h1>Simulations</h1>
            <p>Don’t just read about AI. Build and train models directly in your browser with our visual tools. Explore algorithms, watch learning happen live, and interact with robotics-style planning.</p>
        </div>

        <div class="sim-section">
            <h3 class="sim-section-title"><i class="fas fa-sort-amount-up"></i> Interactive Simulations</h3>
            <p class="sim-section-sub">Hands-on visualizations to understand core algorithms step-by-step.</p>

            <div class="sim-card">
                <div class="sim-card-head">
                    <div>
                        <asp:Label ID="lblSortTitle" runat="server" CssClass="sim-card-title" Text="Sorting Visualizer"></asp:Label>
                        <asp:Label ID="lblSortDesc" runat="server" CssClass="sim-card-sub" Text="Visualize sorting algorithms step by step."></asp:Label>
                    </div>
                    <div class="sim-pill">Interactive</div>
                </div>

                <div class="sim-toolbar">
                    <label>Algorithm</label>
                    <select id="algorithmSelect">
                        <option value="bubble">Bubble Sort</option>
                        <option value="selection">Selection Sort</option>
                        <option value="insertion">Insertion Sort</option>
                        <option value="quick">Quick Sort</option>
                    </select>

                    <button type="button" class="sim-btn" onclick="generateArray()">Generate New Array</button>
                    <button type="button" class="sim-btn sim-btn-primary" onclick="startSort()">Start Simulation</button>

                    <label style="margin-left:auto;">Speed</label>
                    <input type="range" id="speedRange" min="10" max="300" value="100" />
                </div>

                <div id="arrayContainer"></div>

                <div class="sim-stats-row">
                    <div class="sim-pill">Comparisons: <span id="compCount">0</span></div>
                    <div class="sim-pill">Swaps: <span id="swapCount">0</span></div>
                </div>

                <div class="sim-hint"><i class="fas fa-lightbulb text-warning"></i> Tip: Try Quick Sort with higher speed, then slow it down to see each swap.</div>
            </div>
        </div>

        <div class="sim-section">
            <h3 class="sim-section-title"><i class="fas fa-brain"></i> Reinforcement Learning (Q-Learning)</h3>
            <p class="sim-section-sub">Watch learning happen live as the agent improves over training episodes.</p>

            <div class="sim-card">
                <div class="sim-card-head">
                    <div>
                        <asp:Label ID="lblRlTitle" runat="server" CssClass="sim-card-title" Text="RL Grid World"></asp:Label>
                        <asp:Label ID="lblRlDesc" runat="server" CssClass="sim-card-sub" Text="Train a reinforcement learning agent using Q-learning."></asp:Label>
                    </div>
                    <div class="sim-pill">Machine Learning</div>
                </div>

                <div class="sim-toolbar">
                    <label>Mode</label>
                    <select id="rlMode">
                        <option value="wall">Draw Walls</option>
                        <option value="start">Set Start</option>
                        <option value="goal">Set Goal</option>
                        <option value="erase">Erase</option>
                    </select>

                    <label>Episodes</label>
                    <input type="number" id="rlEpisodes" value="300" min="1" style="width:70px;" />

                    <label>α</label>
                    <input type="number" id="rlAlpha" value="0.2" step="0.05" min="0" max="1" style="width:65px;" title="Learning Rate" />

                    <label>γ</label>
                    <input type="number" id="rlGamma" value="0.95" step="0.05" min="0.1" max="0.99" style="width:65px;" title="Discount Factor" />

                    <label>ε</label>
                    <input type="number" id="rlEpsilon" value="0.35" step="0.05" min="0" max="1" style="width:65px;" title="Exploration Rate" />

                    <button type="button" class="sim-btn" onclick="rlReset()" style="margin-left:auto;">Reset</button>
                    <button type="button" class="sim-btn sim-btn-primary" onclick="rlTrain()">Train Agent</button>
                    <button type="button" class="sim-btn" onclick="rlAutoRun()">Auto Run</button>
                    <button type="button" class="sim-btn" onclick="rlStep()">Step</button>
                    <button type="button" class="sim-btn text-danger" onclick="rlStop()">Stop</button>
                </div>

                <div id="rlGrid" class="grid-board"></div>

                <div class="sim-stats-row">
                    <div class="sim-pill">Episode: <span id="rlEpisodeLbl">0</span></div>
                    <div class="sim-pill">Total Reward: <span id="rlRewardLbl">0</span></div>
                    <div class="sim-pill">Epsilon (ε): <span id="rlEpsLbl">0.35</span></div>
                    <div class="sim-pill">Steps: <span id="rlStepsLbl">0</span></div>
                </div>

                <div class="sim-hint"><i class="fas fa-lightbulb text-warning"></i> Tip: Draw walls → Click Train → Once trained, click Auto Run to see the learned policy.</div>
            </div>
        </div>

        <div class="sim-section">
            <h3 class="sim-section-title"><i class="fas fa-robot"></i> Robot Path Planning</h3>
            <p class="sim-section-sub">Applied AI project simulating autonomous navigation using pathfinding logic.</p>

            <div class="sim-card">
                <div class="sim-card-head">
                    <div>
                        <asp:Label ID="lblRobotTitle" runat="server" CssClass="sim-card-title" Text="Path Planning"></asp:Label>
                        <asp:Label ID="lblRobotDesc" runat="server" CssClass="sim-card-sub" Text="Simulate robot navigation using pathfinding algorithms."></asp:Label>
                    </div>
                    <div class="sim-pill">Robotics</div>
                </div>

                <div class="sim-toolbar">
                    <label>Mode</label>
                    <select id="rbMode">
                        <option value="wall">Draw Obstacles</option>
                        <option value="start">Set Robot (Start)</option>
                        <option value="end">Set Goal</option>
                        <option value="erase">Erase</option>
                    </select>

                    <label>Algorithm</label>
                    <select id="rbAlgo">
                        <option value="astar">A* Search (Heuristic)</option>
                        <option value="dijkstra">Dijkstra's (Shortest Path)</option>
                    </select>

                    <label>Speed</label>
                    <input type="range" id="rbSpeed" min="10" max="200" value="35" />

                    <button type="button" class="sim-btn" onclick="rbClearBoard()" style="margin-left:auto;">Clear</button>
                    <button type="button" class="sim-btn" onclick="rbRandomWalls()">Random Maze</button>
                    <button type="button" class="sim-btn sim-btn-primary" onclick="rbRun()">Plan Path</button>
                </div>

                <div id="rbGrid" class="grid-board"></div>

                <div class="sim-stats-row">
                    <div class="sim-pill">Nodes Visited: <span id="rbVisited">0</span></div>
                    <div class="sim-pill">Path Length: <span id="rbPathLen">0</span></div>
                </div>

                <div class="sim-hint"><i class="fas fa-lightbulb text-warning"></i> Tip: A* uses heuristics to find the goal faster, while Dijkstra checks equally in all directions.</div>
            </div>
        </div>
    </div>

<script>
    // =========================================================================
    // Core Logic & Simulation Backend Logging
    // =========================================================================
    function logSimulation(simulationId) {
        // 1. Put the simulation ID into the ASP.NET Hidden Field
        document.getElementById('<%= hfSimId.ClientID %>').value = simulationId;
        
        // 2. Click the hidden ASP.NET button to trigger the secure backend code
        document.getElementById('<%= btnHiddenLog.ClientID %>').click();

        console.log("Logging simulation " + simulationId + " securely via UpdatePanel...");
    }

    function sleep(ms) { return new Promise(r => setTimeout(r, ms)); }

    /* ================= 1. SORTING VISUALIZER ================= */
    let array = [], comparisons = 0, swaps = 0;

    function generateArray() {
        array = [];
        comparisons = 0;
        swaps = 0;
        updateStats();

        const container = document.getElementById("arrayContainer");
        container.innerHTML = "";

        for (let i = 0; i < 28; i++) {
            let val = Math.floor(Math.random() * 220) + 20;
            array.push(val);
            let bar = document.createElement("div");
            bar.style.height = val + "px";
            container.appendChild(bar);
        }
    }

    function updateStats() {
        document.getElementById("compCount").innerText = comparisons;
        document.getElementById("swapCount").innerText = swaps;
    }

    async function startSort() {
        logSimulation(1);
        let algo = document.getElementById("algorithmSelect").value;
        if (algo === "bubble") await bubbleSort();
        if (algo === "selection") await selectionSort();
        if (algo === "insertion") await insertionSort();
        if (algo === "quick") await quickSort(0, array.length - 1);
    }

    async function bubbleSort() {
        let bars = document.getElementById("arrayContainer").children;
        for (let i = 0; i < array.length; i++) {
            for (let j = 0; j < array.length - i - 1; j++) {
                comparisons++; updateStats();
                if (array[j] > array[j + 1]) {
                    swaps++; updateStats();
                    await sleep(document.getElementById("speedRange").value);
                    [array[j], array[j + 1]] = [array[j + 1], array[j]];
                    bars[j].style.height = array[j] + "px";
                    bars[j + 1].style.height = array[j + 1] + "px";
                }
            }
        }
    }

    async function selectionSort() {
        let bars = document.getElementById("arrayContainer").children;
        for (let i = 0; i < array.length; i++) {
            let min = i;
            for (let j = i + 1; j < array.length; j++) {
                comparisons++; updateStats();
                if (array[j] < array[min]) min = j;
            }
            swaps++; updateStats();
            await sleep(document.getElementById("speedRange").value);
            [array[i], array[min]] = [array[min], array[i]];
            bars[i].style.height = array[i] + "px";
            bars[min].style.height = array[min] + "px";
        }
    }

    async function insertionSort() {
        let bars = document.getElementById("arrayContainer").children;
        for (let i = 1; i < array.length; i++) {
            let key = array[i], j = i - 1;
            while (j >= 0 && array[j] > key) {
                comparisons++; swaps++; updateStats();
                array[j + 1] = array[j];
                bars[j + 1].style.height = array[j] + "px";
                j--;
                await sleep(document.getElementById("speedRange").value);
            }
            array[j + 1] = key;
            bars[j + 1].style.height = key + "px";
        }
    }

    async function quickSort(low, high) {
        if (low < high) {
            let pi = await partition(low, high);
            await quickSort(low, pi - 1);
            await quickSort(pi + 1, high);
        }
    }

    async function partition(low, high) {
        let bars = document.getElementById("arrayContainer").children;
        let pivot = array[high];
        let i = low - 1;
        for (let j = low; j < high; j++) {
            comparisons++; updateStats();
            if (array[j] < pivot) {
                i++; swaps++; updateStats();
                await sleep(document.getElementById("speedRange").value);
                [array[i], array[j]] = [array[j], array[i]];
                bars[i].style.height = array[i] + "px";
                bars[j].style.height = array[j] + "px";
            }
        }
        swaps++; updateStats();
        await sleep(document.getElementById("speedRange").value);
        [array[i + 1], array[high]] = [array[high], array[i + 1]];
        bars[i + 1].style.height = array[i + 1] + "px";
        bars[high].style.height = array[high] + "px";
        return i + 1;
    }

    /* ================= 2. RL GRID WORLD (Q-LEARNING) ================= */
    const RL_ROWS = 12;
    const RL_COLS = 18;

    let rlGridEl, rlCells = [], rlWalls = [];
    let rlStart = { r: 1, c: 1 }, rlGoal = { r: RL_ROWS - 2, c: RL_COLS - 2 }, rlAgent = { r: 1, c: 1 };
    let Q = null, rlEpisode = 0, rlTotalReward = 0, rlSteps = 0;
    let rlRunning = false, rlMouseDown = false, rlTimer = null;

    function rlIdx(r, c) { return r * RL_COLS + c; }
    function rlInBounds(r, c) { return r >= 0 && r < RL_ROWS && c >= 0 && c < RL_COLS; }
    function rlStateId(r, c) { return r * RL_COLS + c; }
    function rlSleep(ms) { return new Promise(res => setTimeout(res, ms)); }

    function rlInit() {
        rlGridEl = document.getElementById("rlGrid");
        rlGridEl.style.gridTemplateColumns = `repeat(${RL_COLS}, 22px)`;

        rlWalls = Array.from({ length: RL_ROWS }, () => Array(RL_COLS).fill(0));
        rlCells = [];
        rlGridEl.innerHTML = "";

        for (let r = 0; r < RL_ROWS; r++) {
            for (let c = 0; c < RL_COLS; c++) {
                if (r === 0 || c === 0 || r === RL_ROWS - 1 || c === RL_COLS - 1) rlWalls[r][c] = 1;
            }
        }

        for (let r = 0; r < RL_ROWS; r++) {
            for (let c = 0; c < RL_COLS; c++) {
                const cell = document.createElement("div");
                cell.className = "cell";

                cell.addEventListener("mousedown", () => {
                    if (rlRunning) return;
                    rlMouseDown = true;
                    rlApply(r, c);
                });

                cell.addEventListener("mouseenter", () => {
                    if (rlRunning) return;
                    if (rlMouseDown) rlApply(r, c);
                });

                rlGridEl.appendChild(cell);
                rlCells.push(cell);
            }
        }

        document.addEventListener("mouseup", () => rlMouseDown = false);

        rlResetQ();
        rlResetAgent();
        rlRender();
        rlUpdateStats();
    }

    function rlApply(r, c) {
        const mode = document.getElementById("rlMode").value;
        const isStart = (r === rlStart.r && c === rlStart.c);
        const isGoal = (r === rlGoal.r && c === rlGoal.c);
        if (r === 0 || c === 0 || r === RL_ROWS - 1 || c === RL_COLS - 1) return;

        if (mode === "start") {
            if (isGoal) return;
            rlStart = { r, c };
            rlResetAgent();
        } else if (mode === "goal") {
            if (isStart) return;
            rlGoal = { r, c };
        } else if (mode === "wall") {
            if (isStart || isGoal) return;
            rlWalls[r][c] = 1;
        } else if (mode === "erase") {
            if (isStart || isGoal) return;
            rlWalls[r][c] = 0;
        }

        rlResetQ();
        rlRender();
    }

    function rlReset() {
        rlStop();
        rlWalls = Array.from({ length: RL_ROWS }, () => Array(RL_COLS).fill(0));
        for (let r = 0; r < RL_ROWS; r++) {
            for (let c = 0; c < RL_COLS; c++) {
                if (r === 0 || c === 0 || r === RL_ROWS - 1 || c === RL_COLS - 1) rlWalls[r][c] = 1;
            }
        }
        rlStart = { r: 1, c: 1 };
        rlGoal = { r: RL_ROWS - 2, c: RL_COLS - 2 };
        rlResetQ();
        rlResetAgent();
        rlRender();
        rlUpdateStats();
    }

    function rlResetQ() {
        const states = RL_ROWS * RL_COLS;
        Q = Array.from({ length: states }, () => [0, 0, 0, 0]);
        rlEpisode = 0;
        rlTotalReward = 0;
        rlSteps = 0;
    }

    function rlResetAgent() { rlAgent = { r: rlStart.r, c: rlStart.c }; }

    function rlRender() {
        for (let i = 0; i < rlCells.length; i++) rlCells[i].className = "cell";
        for (let r = 0; r < RL_ROWS; r++) {
            for (let c = 0; c < RL_COLS; c++) {
                if (rlWalls[r][c] === 1) rlCells[rlIdx(r, c)].classList.add("wall");
            }
        }
        rlCells[rlIdx(rlStart.r, rlStart.c)].classList.add("start");
        rlCells[rlIdx(rlGoal.r, rlGoal.c)].classList.add("end");
        rlCells[rlIdx(rlAgent.r, rlAgent.c)].classList.add("visited");
    }

    function rlUpdateStats() {
        document.getElementById("rlEpisodeLbl").innerText = rlEpisode;
        document.getElementById("rlRewardLbl").innerText = rlTotalReward.toFixed(2);
        document.getElementById("rlStepsLbl").innerText = rlSteps;
        document.getElementById("rlEpsLbl").innerText = parseFloat(document.getElementById("rlEpsilon").value).toFixed(2);
    }

    function rlChooseAction(stateId, epsilon) {
        if (Math.random() < epsilon) return Math.floor(Math.random() * 4);
        const arr = Q[stateId];
        let bestA = 0;
        for (let a = 1; a < 4; a++) if (arr[a] > arr[bestA]) bestA = a;
        return bestA;
    }

    function rlStepTransition(r, c, action) {
        const moves = [[-1, 0], [0, 1], [1, 0], [0, -1]];
        const [dr, dc] = moves[action];
        const nr = r + dr, nc = c + dc;
        if (!rlInBounds(nr, nc) || rlWalls[nr][nc] === 1) return { nr: r, nc: c, reward: -0.08, done: false };
        if (nr === rlGoal.r && nc === rlGoal.c) return { nr, nc, reward: +1.0, done: true };
        return { nr, nc, reward: -0.02, done: false };
    }

    async function rlTrain() {
        logSimulation(2);
        rlStop();
        rlRunning = true;
        const episodes = parseInt(document.getElementById("rlEpisodes").value, 10);
        const alpha = parseFloat(document.getElementById("rlAlpha").value);
        const gamma = parseFloat(document.getElementById("rlGamma").value);
        let epsilon = parseFloat(document.getElementById("rlEpsilon").value);

        for (let ep = 1; ep <= episodes; ep++) {
            if (!rlRunning) break;
            rlResetAgent();
            let done = false, epReward = 0, guard = 0;

            while (!done && guard < 500) {
                guard++;
                const s = rlStateId(rlAgent.r, rlAgent.c);
                const a = rlChooseAction(s, epsilon);
                const t = rlStepTransition(rlAgent.r, rlAgent.c, a);
                const s2 = rlStateId(t.nr, t.nc);
                const bestNext = Math.max(...Q[s2]);
                Q[s][a] = Q[s][a] + alpha * (t.reward + gamma * bestNext - Q[s][a]);
                rlAgent = { r: t.nr, c: t.nc };
                epReward += t.reward;
                done = t.done;
            }
            rlEpisode++; rlTotalReward += epReward;
            epsilon = Math.max(0.05, epsilon * 0.995);

            if (ep % 10 === 0) {
                document.getElementById("rlEpsilon").value = epsilon.toFixed(2);
                rlRender(); rlUpdateStats(); await rlSleep(10);
            }
        }
        rlRunning = false; rlResetAgent(); rlRender(); rlUpdateStats();
    }

    async function rlStep() {
        if (rlRunning) return;
        const s = rlStateId(rlAgent.r, rlAgent.c);
        let bestA = 0;
        for (let a = 1; a < 4; a++) if (Q[s][a] > Q[s][bestA]) bestA = a;
        const t = rlStepTransition(rlAgent.r, rlAgent.c, bestA);
        rlAgent = { r: t.nr, c: t.nc };
        rlSteps++; rlTotalReward += t.reward;
        rlRender(); rlUpdateStats();
        if (t.done) { alert("Goal reached!"); rlResetAgent(); rlRender(); }
    }

    function rlAutoRun() {
        logSimulation(2);
        if (rlRunning) return;
        rlRunning = true;
        const tick = () => {
            if (!rlRunning) return;
            const s = rlStateId(rlAgent.r, rlAgent.c);
            let bestA = 0;
            for (let a = 1; a < 4; a++) if (Q[s][a] > Q[s][bestA]) bestA = a;
            const t = rlStepTransition(rlAgent.r, rlAgent.c, bestA);
            rlAgent = { r: t.nr, c: t.nc };
            rlSteps++; rlTotalReward += t.reward;
            rlRender(); rlUpdateStats();
            if (t.done) { rlRunning = false; setTimeout(() => alert("Goal reached!"), 50); rlResetAgent(); rlRender(); return; }
            rlTimer = setTimeout(tick, 60);
        };
        tick();
    }

    function rlStop() { rlRunning = false; if (rlTimer) clearTimeout(rlTimer); rlTimer = null; }

    /* ================= 3. ROBOT PATH PLANNING ================= */
    const RB_ROWS = 15;
    const RB_COLS = 25;
    let rbGridEl, rbCells = [], rbState = [];
    let rbStart = { r: 1, c: 1 }, rbEnd = { r: 13, c: 23 };
    let rbMouseDown = false, rbRunning = false;

    function rbIdx(r, c) { return r * RB_COLS + c; }
    function rbInBounds(r, c) { return r >= 0 && r < RB_ROWS && c >= 0 && c < RB_COLS; }
    function rbSleep(ms) { return new Promise(res => setTimeout(res, ms)); }

    function rbInit() {
        rbGridEl = document.getElementById("rbGrid");
        rbGridEl.style.gridTemplateColumns = `repeat(${RB_COLS}, 22px)`;
        rbCells = [];
        rbState = Array.from({ length: RB_ROWS }, () => Array(RB_COLS).fill(0));
        rbGridEl.innerHTML = "";

        for (let r = 0; r < RB_ROWS; r++) {
            for (let c = 0; c < RB_COLS; c++) {
                const cell = document.createElement("div");
                cell.className = "cell";
                cell.addEventListener("mousedown", () => { if (!rbRunning) { rbMouseDown = true; rbApply(r, c); } });
                cell.addEventListener("mouseenter", () => { if (!rbRunning && rbMouseDown) rbApply(r, c); });
                rbGridEl.appendChild(cell);
                rbCells.push(cell);
            }
        }
        document.addEventListener("mouseup", () => rbMouseDown = false);
        rbRender(); rbUpdateStats(0, 0);
    }

    function rbApply(r, c) {
        const mode = document.getElementById("rbMode").value;
        const isStart = (r === rbStart.r && c === rbStart.c), isEnd = (r === rbEnd.r && c === rbEnd.c);

        if (mode === "start") { if (!isEnd) rbStart = { r, c }; }
        else if (mode === "end") { if (!isStart) rbEnd = { r, c }; }
        else if (mode === "wall") { if (!isStart && !isEnd) rbState[r][c] = 1; }
        else if (mode === "erase") { if (!isStart && !isEnd) rbState[r][c] = 0; }
        rbRender();
    }

    function rbRender() {
        for (let i = 0; i < rbCells.length; i++) rbCells[i].className = "cell";
        for (let r = 0; r < RB_ROWS; r++) {
            for (let c = 0; c < RB_COLS; c++) { if (rbState[r][c] === 1) rbCells[rbIdx(r, c)].classList.add("wall"); }
        }
        rbCells[rbIdx(rbStart.r, rbStart.c)].classList.add("start");
        rbCells[rbIdx(rbEnd.r, rbEnd.c)].classList.add("end");
    }

    function rbClearColors() { for (let i = 0; i < rbCells.length; i++) rbCells[i].classList.remove("visited", "path"); rbRender(); }
    
    function rbClearBoard() {
        if (rbRunning) return;
        for (let r = 0; r < RB_ROWS; r++) for (let c = 0; c < RB_COLS; c++) rbState[r][c] = 0;
        rbRender(); rbUpdateStats(0, 0);
    }

    function rbRandomWalls() {
        if (rbRunning) return;
        rbClearBoard();
        for (let r = 0; r < RB_ROWS; r++) {
            for (let c = 0; c < RB_COLS; c++) {
                if ((r === rbStart.r && c === rbStart.c) || (r === rbEnd.r && c === rbEnd.c)) continue;
                rbState[r][c] = (Math.random() < 0.20) ? 1 : 0;
            }
        }
        rbRender();
    }

    function rbUpdateStats(visited, pathLen) {
        document.getElementById("rbVisited").innerText = visited;
        document.getElementById("rbPathLen").innerText = pathLen;
    }

    function rbH(r, c) { return Math.abs(r - rbEnd.r) + Math.abs(c - rbEnd.c); }

    async function rbRun() {
        logSimulation(3);
        if (rbRunning) return;
        rbRunning = true;
        rbClearColors(); rbUpdateStats(0, 0);

        const algo = document.getElementById("rbAlgo").value;
        const delay = parseInt(document.getElementById("rbSpeed").value, 10);
        const result = (algo === "astar") ? await rbAStar(delay) : await rbDijkstra(delay);

        if (result && result.path) {
            for (const node of result.path) {
                if ((node.r === rbStart.r && node.c === rbStart.c) || (node.r === rbEnd.r && node.c === rbEnd.c)) continue;
                rbCells[rbIdx(node.r, node.c)].classList.add("path");
                await rbSleep(Math.max(5, delay - 10));
            }
            rbUpdateStats(result.visitedCount, result.path.length);
        } else {
            rbUpdateStats(result?.visitedCount ?? 0, 0);
            alert("No path found!");
        }
        rbRunning = false;
    }

    function rbReconstruct(parent) {
        const path = []; let cur = { r: rbEnd.r, c: rbEnd.c };
        if (parent[cur.r][cur.c] == null && !(cur.r === rbStart.r && cur.c === rbStart.c)) return null;
        while (cur) {
            path.push(cur);
            if (cur.r === rbStart.r && cur.c === rbStart.c) break;
            cur = parent[cur.r][cur.c];
        }
        return path.reverse();
    }

    async function rbAStar(delay) {
        const open = [], closed = Array.from({ length: RB_ROWS }, () => Array(RB_COLS).fill(false));
        const parent = Array.from({ length: RB_ROWS }, () => Array(RB_COLS).fill(null));
        const g = Array.from({ length: RB_ROWS }, () => Array(RB_COLS).fill(Infinity));
        const dirs = [[1, 0], [-1, 0], [0, 1], [0, -1]];
        g[rbStart.r][rbStart.c] = 0;
        open.push({ r: rbStart.r, c: rbStart.c, f: rbH(rbStart.r, rbStart.c) });
        let visitedCount = 0;

        while (open.length) {
            open.sort((a, b) => a.f - b.f);
            const cur = open.shift();
            if (closed[cur.r][cur.c]) continue;
            closed[cur.r][cur.c] = true;

            if (!(cur.r === rbStart.r && cur.c === rbStart.c) && !(cur.r === rbEnd.r && cur.c === rbEnd.c)) {
                rbCells[rbIdx(cur.r, cur.c)].classList.add("visited");
                visitedCount++; rbUpdateStats(visitedCount, 0); await rbSleep(delay);
            }
            if (cur.r === rbEnd.r && cur.c === rbEnd.c) return { path: rbReconstruct(parent), visitedCount };

            for (const [dr, dc] of dirs) {
                const nr = cur.r + dr, nc = cur.c + dc;
                if (!rbInBounds(nr, nc) || rbState[nr][nc] === 1 || closed[nr][nc]) continue;
                const tg = g[cur.r][cur.c] + 1;
                if (tg < g[nr][nc]) {
                    g[nr][nc] = tg; parent[nr][nc] = { r: cur.r, c: cur.c };
                    open.push({ r: nr, c: nc, f: tg + rbH(nr, nc) });
                }
            }
        }
        return { path: null, visitedCount };
    }

    async function rbDijkstra(delay) {
        const dist = Array.from({ length: RB_ROWS }, () => Array(RB_COLS).fill(Infinity));
        const visited = Array.from({ length: RB_ROWS }, () => Array(RB_COLS).fill(false));
        const parent = Array.from({ length: RB_ROWS }, () => Array(RB_COLS).fill(null));
        const dirs = [[1, 0], [-1, 0], [0, 1], [0, -1]];
        dist[rbStart.r][rbStart.c] = 0;
        let visitedCount = 0;

        while (true) {
            let best = null, bestD = Infinity;
            for (let r = 0; r < RB_ROWS; r++) {
                for (let c = 0; c < RB_COLS; c++) {
                    if (!visited[r][c] && rbState[r][c] !== 1 && dist[r][c] < bestD) { bestD = dist[r][c]; best = { r, c }; }
                }
            }
            if (!best) break;
            const { r, c } = best; visited[r][c] = true;

            if (!(r === rbStart.r && c === rbStart.c) && !(r === rbEnd.r && c === rbEnd.c)) {
                rbCells[rbIdx(r, c)].classList.add("visited");
                visitedCount++; rbUpdateStats(visitedCount, 0); await rbSleep(delay);
            }
            if (r === rbEnd.r && c === rbEnd.c) return { path: rbReconstruct(parent), visitedCount };

            for (const [dr, dc] of dirs) {
                const nr = r + dr, nc = c + dc;
                if (!rbInBounds(nr, nc) || rbState[nr][nc] === 1 || visited[nr][nc]) continue;
                const nd = dist[r][c] + 1;
                if (nd < dist[nr][nc]) { dist[nr][nc] = nd; parent[nr][nc] = { r, c }; }
            }
        }
        return { path: null, visitedCount };
    }

    window.addEventListener("load", () => {
        generateArray();
        rlInit();
        rbInit();
    });
</script>

</asp:Content>
