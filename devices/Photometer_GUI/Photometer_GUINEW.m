function Photometer_GUINEW
%Select the photometer version currently in use and select an option to
%scale the Y axis. Choose a place to save the data as well as the amount of 
%measurements to be taken. When adjusted, press 'Measure Light' to plot the data.

%Creates the interactive objects.
f = figure('Visible','off','Position',[360,500,830,655]);
set(f, 'color', [.7, .7, .7]);
frame = uipanel('Units','pixels','Position',[610,30,200,595],'BackgroundColor',[.8,.8,.8],'BorderType','beveledin','BorderWidth',2,'ShadowColor',[.9,.9,.9]);
measureButton = uicontrol('Style','pushbutton','String','Measure','Position',[655,420,170,55],'FontSize', 16,'BackgroundColor',[.75,.75,.75],'FontWeight','Bold','Callback',{@measureButton_Callback});
version = uicontrol('Style','text','String','Version','Position',[665,350,120,45],'FontSize', 16,'BackgroundColor',[.8,.8,.8]);
versionMenu = uicontrol('Style','popupmenu','String',{'PR 670','PR 715'},'Position',[600,305,140,55],'FontSize', 16,'Callback',{@versionMenu_Callback});
scaleLabel = uicontrol('Style','text','String','Y Axis Scale','Position',[600,265,130,45],'FontSize', 16,'BackgroundColor',[.8,.8,.8]);
yaxisScale = uicontrol('Style','popupmenu','String',{'Linear','Log'},'Position',[600,220,140,55],'FontSize', 16,'Callback',{@yaxisScale_Callback});
saveFileMenu = uicontrol('Style','pushbutton','String',{'Choose File'},'Position',[600,125,140,55],'FontSize', 16,'BackgroundColor',[.75,.75,.75],'FontWeight','Bold','Callback',{@saveFileMenu_Callback});
saveGraphButton = uicontrol('Style','pushbutton','String','Save Graph','Position',[210, 610, 150, 30],'FontSize', 16,'BackgroundColor',[.85,.85,.85],'Callback',{@saveGraphButton_Callback});
iterationNum = 1;
iterationMenu = uicontrol('Style','edit','String',string(iterationNum),'Position',[655,480,170,55],'FontSize', 16,'Callback',{@iterationMenu_Callback});
iterationText = uicontrol('Style','text','String','Number of Measurements','Position',[655,550,170,55],'FontSize', 16,'BackgroundColor',[.8,.8,.8]);
backButton = uicontrol('Style','pushbutton','String','Back','Position',[70,30,170,35],'FontSize', 12,'BackgroundColor',[.85,.85,.85],'FontWeight','Bold','Callback',{@backButton_Callback});
nextButton = uicontrol('Style','pushbutton','String','Next','Position',[340,30,170,35],'FontSize', 12,'BackgroundColor',[.85,.85,.85],'FontWeight','Bold','Callback',{@nextButton_Callback});
saveTo = uicontrol('Style','text','String','Save Data To','Position',[665,190,130,25],'FontSize', 16,'BackgroundColor',[.8,.8,.8]);
folderButton = uicontrol('Style','pushbutton','String','Select Folder','Position',[655,60,150,45],'FontSize', 16,'BackgroundColor',[.75,.75,.75],'FontWeight','Bold','Callback',{@folderButton_Callback});
panel = uipanel('Units','pixels','Position',[20,80,540,500],'BackgroundColor',[.9,.9,.9],'BorderType','beveledin','BorderWidth',2,'ShadowColor',[.75,.75,.75]);
uistack(panel,'bottom');

%Sets the axes of the graph and turns off the axes that are behind the
%first graph to avoid clutter.
faxes1 = axes('Parent',panel,'Units','pixels','Position',[70,60,400,400]);
xlabel(faxes1, 'Wavelength, nm', 'FontSize', 16)
ylabel(faxes1, 'Irradiance (W/sr/m^2)', 'FontSize', 16)
title(faxes1, 'Wavelength vs Irradiance', 'FontSize', 16)
axesGroup = faxes1;

graph = 1;
graphLabel = sprintf('Graph %d',graph);
graphNum = uicontrol('Style','text','String',graphLabel,'Position',[250,585,70,20],'FontSize', 12,'FontWeight','Bold','BackgroundColor',[.7,.7,.7]);

%Sets objects to align with their centers.
align([measureButton,yaxisScale,version,scaleLabel,versionMenu,saveFileMenu,iterationMenu,iterationText,saveTo,frame,folderButton],'Center','None');
align([backButton,nextButton,graphNum],'None','Center');

%Normalize units to resize automatically.
saveGraphButton.Units = 'normalized';
f.Units = 'normalized';
measureButton.Units = 'normalized';
version.Units = 'normalized';
versionMenu.Units = 'normalized';
scaleLabel.Units = 'normalized';
yaxisScale.Units = 'normalized';
saveFileMenu.Units = 'normalized';
iterationMenu.Units = 'normalized';
iterationText.Units = 'normalized';
backButton.Units = 'normalized';
nextButton.Units = 'normalized';
graphNum.Units = 'normalized';
saveTo.Units = 'normalized';
frame.Units = 'normalized';
folderButton.Units = 'normalized';
panel.Units = 'normalized';

%Gives the GUI a name.
f.Name = 'Photometer GUI';

%Moves GUI to the center.
movegui(f,'center')

iteration = 1; %Default value for number of measurements.

result = [];

test = false;

folder = [];

folderSelect = false;

%Makes the GUI visible.
f.Visible = 'on';
measureIsTrue = 1;
function versionMenu_Callback(source,~) 
    % Determine the selected data set.
    str = source.String;
    val = source.Value;
    % Set current data to the selected data set.
    switch str{val}
        case 'PR 670'
            measureIsTrue = 1;
        case 'PR 715'
            measureIsTrue = 0;
    end
end

numValid = true;

logOn = false;

indexNum = 0;

value = 'Linear';

%Defines the action that occurs when a scale is selected.
function yaxisScale_Callback(source, ~)
    % Determine the selected data set.
    indexNum = 0;
    str = source.String;
    value = source.Value;
    for num = 1:iteration
        cla(axesGroup(num), 'reset')
    end
    % Set current data to the selected data set.
    switch str{value}
        case 'Linear'
            logOn = false;
            for num = 1:2:iteration*2
                if measureIsTrue == 1
                    wav = result(:,num);
                    spd = result(:,num+1);
                elseif measureIsTrue == 0
                    wav = result(num,:);
                    spd = result(num+1,:);
                end
                indexNum = indexNum + 1;
                plot(axesGroup(indexNum), wav, spd)
                xlabel(axesGroup(indexNum), 'Wavelength, nm', 'FontSize', 16)
                ylabel(axesGroup(indexNum), 'Irradiance (W/sr/m^2)', 'FontSize', 16)
                title(axesGroup(indexNum), 'Wavelength vs Irradiance', 'FontSize', 16)
            end
        case 'Log'
            logOn = true;
            for num = 1:2:iteration*2
                if measureIsTrue == 1
                    wav = result(:,num);
                    logSpd = log(result(:,num+1));
                elseif measureIsTrue == 0
                    wav = result(num,:);
                    logSpd = log(result(num+1,:));
                end
                indexNum = indexNum + 1;
                plot(axesGroup(indexNum), wav, logSpd)
                xlabel(axesGroup(indexNum), 'Wavelength, nm', 'FontSize', 16)
                ylabel(axesGroup(indexNum), 'Irradiance (W/sr/m^2)', 'FontSize', 16)
                title(axesGroup(indexNum), 'Wavelength vs Irradiance', 'FontSize', 16)
            end
    end
    for num = 1:iteration
        axis(axesGroup(num), 'off')
    end
    axis(axesGroup(graph), 'on')
end

saveFileName = []; %Sets saveFileName to an empty array.

chooseFile = false;

promptOn = 0;

function saveGraphButton_Callback(~,~)
    if test == true
        h = figure('Position', [100, 400, 550, 550]);
        copyobj(axesGroup(graph), h)
        filename = string(saveFileName);
        saveas(h, strcat(folder,'\',filename,'_','Graph',string(graph)))
    end
end

%Selects the file to save to depending on the text typed.
function saveFileMenu_Callback(~, ~)
    if promptOn == 0
        prompt = figure('Position', [1155,475,470,275]);
        subject = uicontrol(prompt,'Style','edit','String','Select Subject...','Position',[25,160,180,60],'FontSize', 16,'Callback',{@subject_Callback});
        lightCondition = uicontrol(prompt,'Style','popupmenu','String',{'Select Light...','tungsten','blueflashlight','velscope','cst455','blueoraleye','whiteoraleye'},'Position',[270,120,190,85],'FontSize', 16,'Callback',{@lightCondition_Callback});
        filterCondition = uicontrol(prompt,'Style','popupmenu','String',{'Select Filter...','nofilter','hoyak2','hoya25a'},'Position',[25,20,190,85],'FontSize', 16,'Callback',{@filterCondition_Callback});
        apertureCondition = uicontrol(prompt,'Style','popupmenu','String',{'Select Aperture...','quarterdeg','halfdeg','onedeg'},'Position',[270,20,190,85],'FontSize', 16,'Callback',{@apertureCondition_Callback});
        closeButton = uicontrol(prompt,'Style','pushbutton','String','Save/Exit','Position',[165,20,150,45],'FontSize', 16,'FontWeight','Bold','Callback',{@closeButton_Callback});
        closeButton.Units = 'normalized';
        prompt.Units = 'normalized';
        subject.Units = 'normalized';
        lightCondition.Units = 'normalized';
        filterCondition.Units = 'normalized';
        apertureCondition.Units = 'normalized';
    else
        promptOn = 1;
        prompt.Visible = 'on';
    end
    subjectName = [];
    light = [];
    filter = [];
    aperture = [];
    function subject_Callback(source, ~)
        subjectName = source.String;
    end
    function lightCondition_Callback(source, ~)
        str = source.String;
        val = source.Value;
        light = str{val};
    end
    function filterCondition_Callback(source, ~)
        str = source.String;
        val = source.Value;
        filter = str{val};
    end
    function apertureCondition_Callback(source, ~)
        str = source.String;
        val = source.Value;
        aperture = str{val};
    end
    function closeButton_Callback(~, ~)
        if isempty(subjectName)
            msgbox('Select Valid Name', 'Error', 'error')
        elseif isempty(light)
            msgbox('Select Valid Light', 'Error', 'error')
        elseif isempty(filter)
            msgbox('Select Valid Filter', 'Error', 'error')
        elseif isempty(aperture)
            msgbox('Select Valid Aperture', 'Error', 'error')
        else
            saveFileName = strcat(subjectName,'_',light,'_',filter,'_',aperture);
            chooseFile = true;
            disp(saveFileName)
            prompt.Visible = 'off';
        end
    end
end

clearData = 0;

%Defines the action that occurs when a version is selected.
function measureButton_Callback(~, ~)
    result = [];
    if folderSelect == false
        msgbox('Select a folder', 'Error', 'error');
    elseif chooseFile == false
        msgbox('Choose a file', 'Error', 'error');
    elseif numValid == false
        msgbox('Not a Valid Number', 'Error', 'error');
    else
        test = true;
        clearData = clearData + 1;
        if clearData >= 2
            graph = 1;
            graphLabel = sprintf('Graph %d',graph);
            graphNum.String = graphLabel;
            indexNum = 0;
            for num = 1:iteration
                cla(axesGroup(num))
            end
        end
        %Saves the data into the correct row and column for PR 670.
        if measureIsTrue == 1
            for num = 1:2:iteration*2
                [spd, wav, ~, ~] = measure670();
                logSpd = log(spd);
                if logOn == false
                    indexNum = indexNum + 1;
                    plot(axesGroup(indexNum), wav, spd)
                    xlabel(axesGroup(indexNum), 'Wavelength, nm', 'FontSize', 16)
                    ylabel(axesGroup(indexNum), 'Irradiance (W/sr/m^2)', 'FontSize', 16)
                    title(axesGroup(indexNum), 'Wavelength vs Irradiance', 'FontSize', 16)
                else
                    indexNum = indexNum + 1;
                    plot(axesGroup(indexNum), wav, logSpd)
                    xlabel(axesGroup(indexNum), 'Wavelength, nm', 'FontSize', 16)
                    ylabel(axesGroup(indexNum), 'Irradiance (W/sr/m^2)', 'FontSize', 16)
                    title(axesGroup(indexNum), 'Wavelength vs Irradiance', 'FontSize', 16)
                end
                result(:,num) = wav;
                result(:,num+1) = spd;
                radiance(:,indexNum) = result(:,num+1);
            end
            wave(:,1) = wav;
            filename = string(saveFileName);
            save(strcat(folder,'\',filename), 'wave', 'radiance');
            saveas(f, strcat(folder,'\',filename))
            for num = 1:iteration
                axis(axesGroup(num), 'off')
            end
            axis(axesGroup(graph), 'on')
            msgbox('Done!', 'Success');
            z = figure('Position', [100, 400, 550, 550]);
            newGraph = copyobj(axesGroup(1), z);
            for num = 1:iteration
                hold on;
                plot(newGraph, wave, radiance(:,num));
            end
        %Saves the data into the correct row and column for PR 715.
        elseif measureIsTrue == 0
            for num = 1:2:iteration*2
                [spd, wav, ~, ~] = measure715();
                logSpd = log(spd);
                if logOn == false
                    indexNum = indexNum + 1;
                    plot(axesGroup(indexNum), wav, spd)
                    xlabel('Wavelength, nm', 'FontSize', 16)
                    ylabel('Irradiance (W/sr/m^2)', 'FontSize', 16)
                    title('Wavelength vs Irradiance', 'FontSize', 16)
                else
                    indexNum = indexNum + 1;
                    plot(axesGroup(indexNum), wav, logSpd)
                    xlabel(plotGraph, 'Wavelength, nm', 'FontSize', 16)
                    ylabel(plotGraph, 'Irradiance (W/sr/m^2)', 'FontSize', 16)
                    title(plotGraph, 'Wavelength vs Irradiance', 'FontSize', 16)
                end
                result(num,:) = wav;
                result(num+1,:) = spd;
                radiance(indexNum,:) = result(num+1,:);
            end
            wave(1,:) = wav;
            filename = string(saveFileName);
            save(strcat(folder,'\',filename), 'wave', 'radiance');
            saveas(f, strcat(folder,'\',filename))
            z = figure('Position', [100, 400, 550, 550]);
            newGraph = copyobj(axesGroup(1), z);
            for num = 1:iteration
                hold on;
                plot(newGraph, wave, radiance(num,:));
            end
            for num = 1:iteration
                axis(axesGroup(num), 'off')
            end
            axis(axesGroup(graph), 'on')
            msgbox('Done!', 'Success');
        else
            msgbox('Select a Version', 'Error', 'error');
        end
    end
end

%Selects number of measurements to be taken.
function iterationMenu_Callback(source, ~)
    str = source.String;
    if ~isnan(str2double(str))
        iteration = str2double(str);
        if clearData >= 1
            for num = 1:iteration
                if num ~= 1
                    clear axesGroup(num)
                end
            end
            axesGroup = faxes1;
        end
        for num = 1:str2double(str)
            if num ~= 1
                numValid = true;
                iterationNum = iterationNum + 1;
                plotGraph = axes('Parent',panel,'Units','pixels','Position',[70,60,400,400]);
                plotGraph.Units = 'normalized';
                axesGroup = [axesGroup, plotGraph];
                axis(axesGroup(num), 'off')
            end
        end
    else
        numValid = false;
    end
end

%Change the graph shown and updates the graph label.
function backButton_Callback(~,~)
    if test == true
        if graph ~= 1
            graph = graph - 1;
            graphLabel = sprintf('Graph %d',graph);
            graphNum.String = graphLabel;
        end
        for num = 1:iteration
            axis(axesGroup(num), 'off')
        end
        axis(axesGroup(graph), 'on')
        uistack(axesGroup(graph), 'top')
    end
end

%Change the graph shown and updates the graph label.
function nextButton_Callback(~,~)
    if test == true
        if graph ~= iteration
            graph = graph + 1;
            graphLabel = sprintf('Graph %d',graph);
            graphNum.String = graphLabel;
        end
        for num = 1:iteration
            axis(axesGroup(num), 'off')
        end
        axis(axesGroup(graph), 'on')
        uistack(axesGroup(graph), 'top')
    end
end
function folderButton_Callback(~,~)
    folder = uigetdir;
    if folder ~= 0
        folderSelect = true;
    end
end
end
