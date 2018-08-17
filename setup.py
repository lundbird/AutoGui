import setuptools

libpath = r"autogui\src\GUILibrary\bin\Release"

with open("README.md", "r") as fh:
    long_description = fh.read()

setuptools.setup(
    name="autogui",
    version="0.0.3",
    author="Alex Lundberg",
    author_email="alex.lundberg@gmail.com",
    description="Records and automates Winform and WPF applications",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/lundbird/SimpleGUI",
    packages=setuptools.find_packages(),
    classifiers=(
        "Programming Language :: Python",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
    ),
    install_requires=['pythonnet'],
    license='MIT',
    data_files = [(r'Lib\site-packages\autogui\bin',[libpath+r'\GUILibrary.dll',
    libpath+r'\GUILibrary.pdb',
    libpath+r'\Interop.UIAutomationClient.dll',
    libpath+r'\TestApiCore.dll',
    libpath+r'\TestApiCore.pdb',
    libpath+r'\TestApiCore.xml',
    libpath+r'\UIAComWrapper.dll',])]
)