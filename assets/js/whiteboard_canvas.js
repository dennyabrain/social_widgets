export const WhiteboardCanvas = {
  mounted() {
    this.canvas = this.el;
    this.ctx = this.canvas.getContext("2d");
    this.drawing = false;
    this.currentStroke = [];

    // Load initial strokes from data attribute
    const initialStrokes = JSON.parse(this.el.dataset.strokes || "[]");
    initialStrokes.forEach((stroke) => this.drawStroke(stroke));

    // Get drawing config
    this.getConfig = () => ({
      color: this.el.dataset.color || "#000000",
      width: parseInt(this.el.dataset.width || "3"),
    });

    // Mouse event handlers
    this.canvas.addEventListener("mousedown", (e) => this.startDrawing(e));
    this.canvas.addEventListener("mousemove", (e) => this.draw(e));
    this.canvas.addEventListener("mouseup", () => this.stopDrawing());
    this.canvas.addEventListener("mouseleave", () => this.stopDrawing());

    // Touch event handlers for mobile
    this.canvas.addEventListener("touchstart", (e) => {
      e.preventDefault();
      const touch = e.touches[0];
      const mouseEvent = new MouseEvent("mousedown", {
        clientX: touch.clientX,
        clientY: touch.clientY,
      });
      this.canvas.dispatchEvent(mouseEvent);
    });

    this.canvas.addEventListener("touchmove", (e) => {
      e.preventDefault();
      const touch = e.touches[0];
      const mouseEvent = new MouseEvent("mousemove", {
        clientX: touch.clientX,
        clientY: touch.clientY,
      });
      this.canvas.dispatchEvent(mouseEvent);
    });

    this.canvas.addEventListener("touchend", (e) => {
      e.preventDefault();
      const mouseEvent = new MouseEvent("mouseup", {});
      this.canvas.dispatchEvent(mouseEvent);
    });

    // Handle remote strokes from other users
    this.handleEvent("draw_remote_stroke", ({ stroke }) => {
      this.drawStroke(stroke);
    });

    // Handle clear canvas event
    this.handleEvent("clear_canvas", () => {
      this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
    });
  },

  getMousePos(e) {
    const rect = this.canvas.getBoundingClientRect();
    const scaleX = this.canvas.width / rect.width;
    const scaleY = this.canvas.height / rect.height;

    return {
      x: (e.clientX - rect.left) * scaleX,
      y: (e.clientY - rect.top) * scaleY,
    };
  },

  startDrawing(e) {
    this.drawing = true;
    const pos = this.getMousePos(e);
    const config = this.getConfig();

    this.currentStroke = {
      points: [pos],
      color: config.color,
      width: config.width,
    };

    this.ctx.beginPath();
    this.ctx.moveTo(pos.x, pos.y);
  },

  draw(e) {
    if (!this.drawing) return;

    const pos = this.getMousePos(e);
    this.currentStroke.points.push(pos);

    const config = this.getConfig();
    this.ctx.strokeStyle = config.color;
    this.ctx.lineWidth = config.width;
    this.ctx.lineCap = "round";
    this.ctx.lineJoin = "round";

    this.ctx.lineTo(pos.x, pos.y);
    this.ctx.stroke();
  },

  stopDrawing() {
    if (!this.drawing) return;

    this.drawing = false;

    // Send stroke to server
    if (this.currentStroke.points.length > 0) {
      this.pushEvent("draw_stroke", {
        stroke: this.currentStroke,
      });
    }

    this.currentStroke = [];
  },

  drawStroke(stroke) {
    if (!stroke || !stroke.points || stroke.points.length === 0) return;

    this.ctx.strokeStyle = stroke.color || "#000000";
    this.ctx.lineWidth = stroke.width || 3;
    this.ctx.lineCap = "round";
    this.ctx.lineJoin = "round";

    this.ctx.beginPath();
    this.ctx.moveTo(stroke.points[0].x, stroke.points[0].y);

    for (let i = 1; i < stroke.points.length; i++) {
      this.ctx.lineTo(stroke.points[i].x, stroke.points[i].y);
    }

    this.ctx.stroke();
  },

  updated() {
    // Update config when color/width changes
    const config = this.getConfig();
    this.currentColor = config.color;
    this.currentWidth = config.width;
  },
};
