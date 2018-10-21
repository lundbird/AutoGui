import setuptools

libpath = r"autogui\src\GUILibrary\bin\Release"

with open("README.md", "r") as fh:
    long_description = fh.read()

setuptools.setup(
    name="autogui",
    version="0.1.7",
    author="Alex Lundberg","Richard Boettcher",
    author_email="alex.lundberg@gmail.com","richard.boettcher@sandc.com",
    description="Records and automates Winform and WPF applications",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/lundbird/SimpleGUI",
    packages=['autogui'],
    package_data={'autogui':['src/GUILibrary/bin/Release/*.dll']},
    classifiers=(
        "Programming Language :: Python",
        "License :: OSI Approved :: MIT License",
        "Operating System :: will only function on Winform/WPF applications",
    ),
    install_requires=['pythonnet'],
    license='MIT',
)