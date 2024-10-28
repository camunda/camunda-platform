class TaskError(Exception):
    """Custom exception for task-related errors."""
    pass


class Task:
    def __init__(self, title, description, priority):
        if priority not in ['Low', 'Medium', 'High']:
            raise TaskError("Priority must be Low, Medium, or High.")
        self.title = title
        self.description = description
        self.priority = priority
        self.completed = False

    def complete_task(self):
        self.completed = True

    def __str__(self):
        status = "✔️" if self.completed else "❌"
        return f"[{status}] {self.title} (Priority: {self.priority})"


class TaskManager:
    def __init__(self):
        self.tasks = []

    def add_task(self, title, description, priority):
        try:
            task = Task(title, description, priority)
            self.tasks.append(task)
            print(f"Task '{title}' added successfully.")
        except TaskError as e:
            print(f"Error adding task: {e}")

    def complete_task(self, title):
        for task in self.tasks:
            if task.title == title:
                task.complete_task()
                print(f"Task '{title}' marked as completed.")
                return
        print(f"Task '{title}' not found.")

    def delete_task(self, title):
        self.tasks = [task for task in self.tasks if task.title != title]
        print(f"Task '{title}' deleted successfully.")

    def view_tasks(self):
        if not self.tasks:
            print("No tasks available.")
            return
        print("Tasks:")
        for task in sorted(self.tasks, key=lambda t: t.priority):
            print(task)

    def filter_tasks(self, completed=None):
        filtered_tasks = self.tasks
        if completed is not None:
            filtered_tasks = [task for task in self.tasks if task.completed == completed]
        
        if not filtered_tasks:
            print("No tasks match the criteria.")
            return
        
        print("Filtered Tasks:")
        for task in filtered_tasks:
            print(task)


# Example usage
if __name__ == "__main__":
    manager = TaskManager()
    manager.add_task("Write report", "Complete the annual report", "High")
    manager.add_task("Email team", "Send out the meeting agenda", "Medium")
    manager.add_task("Clean desk", "Organize desk space", "Low")

    manager.view_tasks()

    manager.complete_task("Write report")
    manager.filter_tasks(completed=True)

    manager.delete_task("Clean desk")
    manager.view_tasks()
