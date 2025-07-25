class Picture:
    def __init__(self, id, binary, width, height):
        self.id = id
        self.binary = binary
        self.width = width
        self.height = height

    def persist(self, output_dir="."):

        output_filename = f"{output_dir}/pic_{self.id}_{self.width}-{self.height}"

        with open(f"{output_filename}.bmp", "wb") as file:
            file.write(self.binary)

