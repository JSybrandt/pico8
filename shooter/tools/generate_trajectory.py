#!/usr/bin/env python3

"""Generates LUA code for trajectories.

We want a display and an editable table.
We also want a "to lua" button.


We should see a 128x128 view of the trajectory, with a helpful animation.


"""

import tkinter as tk
from tkinter import messagebox
import dataclasses
import math


@dataclasses.dataclass
class MoveStep:
    """Move to this location."""

    pos: tuple[int, int]
    speed: float

    def __str__(self):
        return ("add(steps, { cmd=_traj_step_move, "
               f"pos=_v2({self.pos[0]},{self.pos[1]}), "
               f"speed={self.speed} }})")


@dataclasses.dataclass
class JumpStep:
    """Jump to this location."""

    pos: tuple[int, int]

    def __str__(self):
        return ("add(steps, { cmd=_traj_step_jump, "
               f"pos=_v2({self.pos[0]},{self.pos[1]}) }})")


@dataclasses.dataclass
class WaitStep:
    """Wait."""

    count: int

    def __str__(self):
        return ("add(steps, { cmd=_traj_step_wait, "
               f"count = {self.count} }})")

class Actor:
    def __init__(self, app):
        self.app = app
        self.pos = [0, 0]
        self.step_idx = 0
        self.step_counter = 0
        self.radius = 18

    def draw(self):
        if len(self.app.steps) == 0:
            return
        x, y = self.app.to_canvas_px(self.pos)
        left = x - self.radius
        right = x + self.radius
        top = y - self.radius
        bottom = y + self.radius
        self.app.canvas.create_oval(left, top, right, bottom, fill="blue")

    def next_step(self):
        self.step_idx = (self.step_idx + 1) % len(self.app.steps)
        self.step_counter = 0

    def update(self):
        if len(self.app.steps) == 0:
            return
        cmd = self.app.steps[self.step_idx]
        self.step_counter += 1
        if isinstance(cmd, JumpStep):
            self.pos[0] = cmd.pos[0]
            self.pos[1] = cmd.pos[1]
            self.next_step()
        elif isinstance(cmd, WaitStep):
            if self.step_counter >= cmd.count:
                self.next_step()
        elif isinstance(cmd, MoveStep):
            d_x = cmd.pos[0] - self.pos[0]
            d_y = cmd.pos[1] - self.pos[1]
            d_mag = math.sqrt(d_x ** 2 + d_y**2)
            if d_mag < cmd.speed:
                self.pos[0] = cmd.pos[0]
                self.pos[1] = cmd.pos[1]
                self.next_step()
            else:
                self.pos[0] += d_x / d_mag * cmd.speed
                self.pos[1] += d_y / d_mag * cmd.speed



class App(tk.Tk):
    """This helps us make trajectories."""

    def __init__(self):
        super().__init__()
        self.title("Generate Trajectories")

        self.grid_px = 20
        self.game_grid_size = 32
        self.game_grid_margin_size = 3
        self.canvas_px = (self.game_grid_size + 2*self.game_grid_margin_size) * self.grid_px
        self.canvas = tk.Canvas(self, width=self.canvas_px, height=self.canvas_px)
        self.canvas.grid(row=0, column=0, rowspan=7)
        self.canvas.bind("<Button-1>", self.canvas_lclick_fn)
        self.canvas.bind("<Button-3>", self.canvas_rclick_fn)

        self.step_list = tk.Listbox(self, height=10)
        self.step_list.grid(row=0, column=1, rowspan=7)

        self.export_button = tk.Button(
            self, text="Export", command=self.export_button_fn
        )
        self.export_button.grid(row=0, column=2)

        self.clear_button = tk.Button(
            self, text="Delete", command=self.delete_button_fn
        )
        self.clear_button.grid(row=1, column=2)

        self.speed_label = tk.Label(self, text="Speed:")
        self.speed_label.grid(row=2, column=2)
        self.speed_entry = tk.Entry(self, width=15)
        self.speed_entry.grid(row=3, column=2)
        self.speed_entry.insert(0, "1")

        self.wait_label = tk.Label(self, text="Wait Time:")
        self.wait_label.grid(row=4, column=2)
        self.wait_entry = tk.Entry(self, width=15)
        self.wait_entry.grid(row=5, column=2)
        self.wait_entry.insert(0, "15")
        self.wait_button = tk.Button(self, text="Wait", command=self.wait_button_fn)
        self.wait_button.grid(row=6, column=2)

        self.steps = []

        self.actor = Actor(self)

        # We need to kickstart the canvas drawing loop.
        self.draw_canvas()

        self.bind('<BackSpace>', self.delete_button_fn)
        self.bind('w', self.wait_button_fn)

    def to_pico8_v2(self, pos):
        game_px = self.grid_px * self.game_grid_size
        margin_px = self.grid_px * self.game_grid_margin_size
        canvas_to_pico8_ratio = 128 / game_px
        x = (pos[0] - margin_px) * canvas_to_pico8_ratio
        y = (pos[1] - margin_px) * canvas_to_pico8_ratio
        return int(x), int(y)

    def to_canvas_px(self, pico8_pos):
        game_px = self.grid_px * self.game_grid_size
        margin_px = self.grid_px * self.game_grid_margin_size
        pico8_to_canvas_ratio = game_px / 128
        x = pico8_pos[0] * pico8_to_canvas_ratio + margin_px
        y = pico8_pos[1] * pico8_to_canvas_ratio + margin_px
        return int(x), int(y)


    def export_button_fn(self):
        """Exports the steps in lau format"""
        msg = "\n".join(["steps = {}"] + [str(s) for s in self.steps])
        self.clipboard_clear()
        self.clipboard_append(msg)
        self.update()
        messagebox.showinfo(message="Commands copied to clipboard.")

    def delete_button_fn(self, *args, **kwargs):
        """Removes last step"""
        self.steps.pop()
        self.update_step_list()

    def wait_button_fn(self, *args, **kwargs):
        """Adds a wait step."""
        self.steps.append(WaitStep(int(self.wait_entry.get())))
        self.update_step_list()

    def to_closest_grid_square(self, event):
        x = round(event.x / self.grid_px) * self.grid_px
        y = round(event.y / self.grid_px) * self.grid_px
        return (x, y)

    def canvas_lclick_fn(self, event):
        """Adds a move command."""
        self.steps.append(
            MoveStep(pos=self.to_pico8_v2(self.to_closest_grid_square(event)),
                     speed=float(self.speed_entry.get()))
        )
        self.update_step_list()

    def canvas_rclick_fn(self, event):
        """Adds a move command."""
        self.steps.append(JumpStep(pos=self.to_pico8_v2(self.to_closest_grid_square(event))))
        self.update_step_list()

    def update_step_list(self):
        """Refreshes the list of steps."""
        self.step_list.delete(0, "end")
        for step in self.steps:
            self.step_list.insert("end", str(step))

    def draw_positions(self):
        """Draws little markers at each position."""
        marker_radius = 9
        marker_color = "red"
        for step in self.steps:
            if not hasattr(step, "pos"):
                continue
            x, y = self.to_canvas_px(step.pos)
            left = x - marker_radius
            right = x + marker_radius
            top = y - marker_radius
            bottom = y + marker_radius
            self.canvas.create_oval(left, top, right, bottom, fill=marker_color)


    def draw_arrow(self, tail, tip, dashed):
        """Draws an arrow from tail to tip."""
        tail = self.to_canvas_px(tail)
        tip = self.to_canvas_px(tip)
        self.canvas.create_line(tail, tip, arrow=tk.LAST, smooth=True, width=5,
                                dash=(4, 4) if dashed else None)

    def draw_motions(self):
        """Draws a series of arrows."""
        last_pos = None
        for step in self.steps:
            if not hasattr(step, "pos"):
                continue
            if last_pos is not None:
                self.draw_arrow(last_pos, step.pos, dashed=isinstance(step, JumpStep))
            last_pos = step.pos

    def draw_grid(self):
        """Draws a square grid."""
        for x in range(0, self.canvas_px, self.grid_px):
            self.canvas.create_line(x, 0, x, self.canvas_px)
        for y in range(0, self.canvas_px, self.grid_px):
            self.canvas.create_line(0, y, self.canvas_px, y)

    def draw_game_border(self):
        """Draws a thick rectangle around the game viewscreen."""
        margin_px = self.grid_px * self.game_grid_margin_size
        game_px= self.grid_px * self.game_grid_size
        self.canvas.create_rectangle(margin_px,margin_px,game_px+margin_px,
                                     game_px+margin_px, width=4,
                                     outline="grey")


    def draw_canvas(self):
        """Updates the canvas with the contents of the steps list."""
        # Clear canvas.
        self.canvas.delete("all")
        self.canvas.create_rectangle(0,0,self.canvas_px, self.canvas_px)
        self.draw_grid()
        self.draw_game_border()
        self.draw_positions()
        self.draw_motions()
        self.actor.update()
        self.actor.draw()
        # 33 ms is about 30 frames per second.
        self.canvas.after(33, self.draw_canvas)


if __name__ == "__main__":
    app = App()
    app.mainloop()
