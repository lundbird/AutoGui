import setuptools

libpath = r"autogui\src\GUILibrary\bin\Release"

with open("README.md", "r") as fh:
    long_description = fh.read()

setuptools.setup(
    name="autogui",
    version="0.1.6",
    author="Alex Lundberg",
    author_email="alex.lundberg@gmail.com",
    description="Records and automates Winform and WPF applications",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/lundbird/SimpleGUI",
    packages=['autogui'],
    package_data={'autogui':['src/GUILibrary/bin/Release/*.dll']},
    classifiers=(
        "Programming Language :: Python",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
    ),
    install_requires=['pythonnet'],
    license='MIT',
)