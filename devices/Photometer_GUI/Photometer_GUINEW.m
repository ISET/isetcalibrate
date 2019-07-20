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
saveFileMenu = uicontrol('Style','edit','String',{'Choose File...'},'Position',[600,125,140,55],'FontSize', 16,'Callback',{@saveFileMenu_Callback});
iterationMenu = uicontrol('Style','popupmenu','String',{'1','2','3','4','5'},'Position',[655,480,170,55],'FontSize', 16,'Callback',{@iterationMenu_Callback});
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
title(faxes1, 'Comparing Wavelength of Light to Its Irradiance', 'FontSize', 16)
faxes2 = axes('Parent',panel,'Units','pixels','Position',[70,60,400,400],'Color','none','YColor','none');
faxes2.Visible = 'off';
faxes3 = axes('Parent',panel,'Units','pixels','Position',[70,60,400,400],'Color','none','YColor','none');
faxes3.Visible = 'off';
faxes4 = axes('Parent',panel,'Units','pixels','Position',[70,60,400,400],'Color','none','YColor','none');
faxes4.Visible = 'off';
faxes5 = axes('Parent',panel,'Units','pixels','Position',[70,60,400,400],'Color','none','YColor','none');
faxes5.Visible = 'off';
axesGroup = [faxes1, faxes2, faxes3, faxes4, faxes5];

uistack(faxes2, 'top');
uistack(faxes3, 'top');
uistack(faxes4, 'top');
uistack(faxes5, 'top');
uistack(faxes1, 'top');

graph = 1;
graphLabel = sprintf('Graph %d',graph);
graphNum = uicontrol('Style','text','String',graphLabel,'Position',[250,595,70,20],'FontSize', 12,'FontWeight','Bold','BackgroundColor',[.7,.7,.7]);

%Sets objects to align with their centers.
align([measureButton,yaxisScale,version,scaleLabel,versionMenu,saveFileMenu,iterationMenu,iterationText,saveTo,frame,folderButton],'Center','None');
align([backButton,nextButton,graphNum],'None','Center');

%Normalize units to resize automatically.
f.Units = 'normalized';
measureButton.Units = 'normalized';
version.Units = 'normalized';
versionMenu.Units = 'normalized';
scaleLabel.Units = 'normalized';
yaxisScale.Units = 'normalized';
faxes1.Units = 'normalized';
faxes2.Units = 'normalized';
faxes3.Units = 'normalized';
faxes4.Units = 'normalized';
faxes5.Units = 'normalized';
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

result = zeros(87);

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

logOn = false;

value = 'Linear';

%Defines the action that occurs when a scale is selected.
function yaxisScale_Callback(source, ~)
    % Determine the selected data set.
    str = source.String;
    value = source.Value;
    % Set current data to the selected data set.
    switch str{value}
        case 'Linear'
            for num = 1:iteration
                cla(axesGroup(num), 'reset')
            end
            logOn = false;
            for num = 1:2:iteration*2
                if measureIsTrue == 1
                    wav = result(:,num);
                    spd = result(:,num+1);
                elseif measureIsTrue == 0
                    wav = result(num,:);
                    spd = result(num+1,:);
                end
                if num == 1
                    plot(faxes1, wav, spd);
                    xlabel(faxes1, 'Wavelength, nm', 'FontSize', 16)
                    ylabel(faxes1, 'Irradiance (W/sr/m^2)', 'FontSize', 16)
                    title(faxes1, 'Comparing Wavelength of Light to Its Irradiance', 'FontSize', 16)
                    if graph ~= 1
                        faxes1.Visible = 'off';
                        axis(faxes1, 'off')
                    end
                elseif num == 3
                    plot(faxes2, wav, spd);
                    xlabel(faxes2, 'Wavelength, nm', 'FontSize', 16)
                    ylabel(faxes2, 'Irradiance (W/sr/m^2)', 'FontSize', 16)
                    title(faxes2, 'Comparing Wavelength of Light to Its Irradiance', 'FontSize', 16)
                    if graph ~= 2
                        faxes2.Visible = 'off';
                        axis(faxes2, 'off')
                    end
                elseif num == 5
                    plot(faxes3, wav, spd);
                    xlabel(faxes3, 'Wavelength, nm', 'FontSize', 16)
                    ylabel(faxes3, 'Irradiance (W/sr/m^2)', 'FontSize', 16)
                    title(faxes3, 'Comparing Wavelength of Light to Its Irradiance', 'FontSize', 16)
                    if graph ~= 3
                        faxes3.Visible = 'off';
                        axis(faxes3, 'off')
                    end
                elseif num == 7
                    plot(faxes4, wav, spd);
                    xlabel(faxes4, 'Wavelength, nm', 'FontSize', 16)
                    ylabel(faxes4, 'Irradiance (W/sr/m^2)', 'FontSize', 16)
                    title(faxes4, 'Comparing Wavelength of Light to Its Irradiance', 'FontSize', 16)
                    if graph ~= 4
                        faxes4.Visible = 'off';
                        axis(faxes4, 'off')
                    end
                else
                    plot(faxes5, wav, spd);
                    xlabel(faxes5, 'Wavelength, nm', 'FontSize', 16)
                    ylabel(faxes5, 'Irradiance (W/sr/m^2)', 'FontSize', 16)
                    title(faxes5, 'Comparing Wavelength of Light to Its Irradiance', 'FontSize', 16)
                    if graph ~= 5
                        faxes5.Visible = 'off';
                        axis(faxes5, 'off')
                    end
                end
            end
            for num = 1:iteration
                    if axesGroup(num) == graph
                        uistack(axesGroup(num), 'top');
                        axis(axesGroup(1:5), 'off');
                        axis(axesGroup(num), 'on');
                    end
            end
        case 'Log'
            for num = 1:iteration
                cla(axesGroup(num), 'reset')
            end
            logOn = true;
            for num = 1:2:iteration*2
                if measureIsTrue == 1
                    wav = result(:,num);
                    logSpd = log(result(:,num+1));
                elseif measureIsTrue == 0
                    wav = result(num,:);
                    logSpd = log(result(num+1,:));
                end
                if num == 1
                    plot(faxes1, wav, logSpd);
                    xlabel(faxes1, 'Wavelength, nm', 'FontSize', 16)
                    ylabel(faxes1, 'Irradiance (W/sr/m^2)', 'FontSize', 16)
                    title(faxes1, 'Comparing Wavelength of Light to Its Irradiance', 'FontSize', 16)
                    if graph ~= 1
                        faxes1.Visible = 'off';
                        axis(faxes1, 'off')
                    end
                elseif num == 3
                    plot(faxes2, wav, logSpd);
                    xlabel(faxes2, 'Wavelength, nm', 'FontSize', 16)
                    ylabel(faxes2, 'Irradiance (W/sr/m^2)', 'FontSize', 16)
                    title(faxes2, 'Comparing Wavelength of Light to Its Irradiance', 'FontSize', 16)
                    if graph ~= 2
                        faxes2.Visible = 'off';
                        axis(faxes2, 'off')
                    end
                elseif num == 5
                    plot(faxes3, wav, logSpd);
                    xlabel(faxes3, 'Wavelength, nm', 'FontSize', 16)
                    ylabel(faxes3, 'Irradiance (W/sr/m^2)', 'FontSize', 16)
                    title(faxes3, 'Comparing Wavelength of Light to Its Irradiance', 'FontSize', 16)
                    if graph ~= 3
                        faxes3.Visible = 'off';
                        axis(faxes3, 'off')
                    end
                elseif num == 7
                    plot(faxes4, wav, logSpd);
                    xlabel(faxes4, 'Wavelength, nm', 'FontSize', 16)
                    ylabel(faxes4, 'Irradiance (W/sr/m^2)', 'FontSize', 16)
                    title(faxes4, 'Comparing Wavelength of Light to Its Irradiance', 'FontSize', 16)
                    if graph ~= 4
                        faxes4.Visible = 'off';
                        axis(faxes4, 'off')
                    end
                else
                    plot(faxes5, wav, logSpd);
                    xlabel(faxes5, 'Wavelength, nm', 'FontSize', 16)
                    ylabel(faxes5, 'Irradiance (W/sr/m^2)', 'FontSize', 16)
                    title(faxes5, 'Comparing Wavelength of Light to Its Irradiance', 'FontSize', 16)
                    if graph ~= 5
                        faxes5.Visible = 'off';
                        axis(faxes5, 'off')
                    end
                end
            end
            for num = 1:iteration
                    if axesGroup(num) == graph
                        uistack(axesGroup(num), 'top');
                        axis(axesGroup(1:5), 'off');
                        axis(axesGroup(num), 'on');
                    end
            end
    end
end

saveFileName = []; %Sets saveFileName to an empty array.

chooseFile = false;

%Selects the file to save to depending on the text typed.
function saveFileMenu_Callback(source, ~)
    str = source.String;
    saveFileName = str;
    chooseFile = true;
    disp(saveFileName)
end

clearData = 0;
%Defines the action that occurs when a version is selected.
function measureButton_Callback(~, ~)
    if folderSelect == false
        msgbox('Select a folder', 'Error', 'error');
    elseif chooseFile == false
        msgbox('Choose a file', 'Error', 'error');
    else
        test = true;
        clearData = clearData + 1;
        if clearData >= 2
            graph = 1;
            graphLabel = sprintf('Graph %d',graph);
            graphNum.String = graphLabel;
            for num = 1:iteration
                cla(axesGroup(num))
            end
        end
        %Saves the data into the correct row and column for PR 670.
        if measureIsTrue == 1
            for num = 1:2:iteration*2
                [spd, wav, ~, ii] = measure670();
                logSpd = log(spd);
                if logOn == false
                    if num == 1
                        plot(faxes1, wav, spd);
                        xlabel(faxes1, 'Wavelength, nm', 'FontSize', 16)
                        ylabel(faxes1, 'Irradiance (W/sr/m^2)', 'FontSize', 16)
                        title(faxes1, 'Comparing Wavelength of Light to Its Irradiance', 'FontSize', 16)
                        uistack(faxes1, 'top');
                    elseif num == 3
                        plot(faxes2, wav, spd);
                        faxes2.Visible = 'off';
                    elseif num == 5
                        plot(faxes3, wav, spd);
                        faxes3.Visible = 'off';
                    elseif num == 7
                        plot(faxes4, wav, spd);
                        faxes4.Visible = 'off';
                    else
                        plot(faxes5, wav, spd);
                        faxes5.Visible = 'off';
                    end
                else
                    if num == 1
                        plot(faxes1, wav, logSpd);
                        xlabel(faxes1, 'Wavelength, nm', 'FontSize', 16)
                        ylabel(faxes1, 'Irradiance (W/sr/m^2)', 'FontSize', 16)
                        title(faxes1, 'Comparing Wavelength of Light to Its Irradiance', 'FontSize', 16)
                    elseif num == 3
                        plot(faxes2, wav, logSpd);
                        faxes2.Visible = 'off';
                    elseif num == 5
                        plot(faxes3, wav, logSpd);
                        faxes3.Visible = 'off';
                    elseif num == 7
                        plot(faxes4, wav, logSpd);
                        faxes4.Visible = 'off';
                    else
                        plot(faxes5, wav, logSpd);
                        faxes5.Visible = 'off';
                    end
                end
                result(:,num) = wav;
                result(:,num+1) = spd;
                filename = sprintf(string(saveFileName), ii);
                save(strcat(folder,'\',filename), 'result');
                saveas(f, strcat(folder,'\',filename));
            end
            msgbox('Done!', 'Success');
        %Saves the data into the correct row and column for PR 715.
        elseif measureIsTrue == 0
            for num = 1:2:iteration*2
                [spd, wav, ~, ii] = measure715();
                logSpd = log(spd);
                if logOn == false
                    if num == 1
                        plot(faxes1, wav, spd);
                        xlabel(faxes1, 'Wavelength, nm', 'FontSize', 16)
                        ylabel(faxes1, 'Irradiance (W/sr/m^2)', 'FontSize', 16)
                        title(faxes1, 'Comparing Wavelength of Light to Its Irradiance', 'FontSize', 16)
                    elseif num == 3
                        plot(faxes2, wav, spd);
                    elseif num == 5
                        plot(faxes3, wav, spd);
                    elseif num == 7
                        plot(faxes4, wav, spd);
                    else
                        plot(faxes5, wav, spd);
                    end
                else
                    if num == 1
                        plot(faxes1, wav, logSpd);
                        xlabel(faxes1, 'Wavelength, nm', 'FontSize', 16)
                        ylabel(faxes1, 'Irradiance (W/sr/m^2)', 'FontSize', 16)
                        title(faxes1, 'Comparing Wavelength of Light to Its Irradiance', 'FontSize', 16)
                    elseif num == 3
                        plot(faxes2, wav, logSpd);
                    elseif num == 5
                        plot(faxes3, wav, logSpd);
                    elseif num == 7
                        plot(faxes4, wav, logSpd);
                    else
                        plot(faxes5, wav, logSpd);
                    end
                end
                result(num,:) = wav;
                result(num+1,:) = spd;
                filename = sprintf(string(saveFileName), ii);
                save(strcat(folder,'\',filename), 'result');
                saveas(f, strcat(folder,'\',filename));
            end
            msgbox('Done!', 'Success');
        else
            msgbox('Select a Version', 'Error', 'error');
        end
    end
end

%Selects number of measurements to be taken.
function iterationMenu_Callback(source, ~)
    str = source.String;
    val = source.Value;
    switch str{val}
        case '1'
            iteration = 1;
        case '2'
            iteration = 2;
        case '3'
            iteration = 3;
        case '4'
            iteration = 4;
        case '5'
            iteration = 5;
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
        if graph == 1
            uistack(faxes1, 'top');
            faxes1.Visible = 'on';
            faxes2.Visible = 'off';
            faxes3.Visible = 'off';
            faxes4.Visible = 'off';
            faxes5.Visible = 'off';
        elseif graph == 2
            uistack(faxes2, 'top');
            faxes2.Visible = 'on';
            xlabel(faxes2, 'Wavelength, nm', 'FontSize', 16)
            ylabel(faxes2, 'Irradiance (W/sr/m^2)', 'FontSize', 16)
            title(faxes2, 'Comparing Wavelength of Light to Its Irradiance', 'FontSize', 16)
            faxes1.Visible = 'off';
            faxes3.Visible = 'off';
            faxes4.Visible = 'off';
            faxes5.Visible = 'off';
        elseif graph == 3
            uistack(faxes3, 'top');
            faxes3.Visible = 'on';
            xlabel(faxes3, 'Wavelength, nm', 'FontSize', 16)
            ylabel(faxes3, 'Irradiance (W/sr/m^2)', 'FontSize', 16)
            title(faxes3, 'Comparing Wavelength of Light to Its Irradiance', 'FontSize', 16)
            faxes1.Visible = 'off';
            faxes2.Visible = 'off';
            faxes4.Visible = 'off';
            faxes5.Visible = 'off';
        elseif graph == 4
            uistack(faxes4, 'top');
            faxes4.Visible = 'on';
            xlabel(faxes4, 'Wavelength, nm', 'FontSize', 16)
            ylabel(faxes4, 'Irradiance (W/sr/m^2)', 'FontSize', 16)
            title(faxes4, 'Comparing Wavelength of Light to Its Irradiance', 'FontSize', 16)
            faxes1.Visible = 'off';
            faxes3.Visible = 'off';
            faxes2.Visible = 'off';
            faxes5.Visible = 'off';
        end
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
        if graph == 2
            uistack(faxes2, 'top');
            faxes2.Visible = 'on';
            xlabel(faxes2, 'Wavelength, nm', 'FontSize', 16)
            ylabel(faxes2, 'Irradiance (W/sr/m^2)', 'FontSize', 16)
            title(faxes2, 'Comparing Wavelength of Light to Its Irradiance', 'FontSize', 16)
            faxes1.Visible = 'off';
            faxes3.Visible = 'off';
            faxes4.Visible = 'off';
            faxes5.Visible = 'off';
        elseif graph == 3
            faxes3.Visible = 'on';
            xlabel(faxes3, 'Wavelength, nm', 'FontSize', 16)
            ylabel(faxes3, 'Irradiance (W/sr/m^2)', 'FontSize', 16)
            title(faxes3, 'Comparing Wavelength of Light to Its Irradiance', 'FontSize', 16)
            uistack(faxes3, 'top');
            faxes1.Visible = 'off';
            faxes2.Visible = 'off';
            faxes4.Visible = 'off';
            faxes5.Visible = 'off';
        elseif graph == 4
            faxes4.Visible = 'on';
            xlabel(faxes4, 'Wavelength, nm', 'FontSize', 16)
            ylabel(faxes4, 'Irradiance (W/sr/m^2)', 'FontSize', 16)
            title(faxes4, 'Comparing Wavelength of Light to Its Irradiance', 'FontSize', 16)
            uistack(faxes4, 'top');
            faxes1.Visible = 'off';
            faxes3.Visible = 'off';
            faxes2.Visible = 'off';
            faxes5.Visible = 'off';
        elseif graph == 5
            faxes5.Visible = 'on';
            xlabel(faxes5, 'Wavelength, nm', 'FontSize', 16)
            ylabel(faxes5, 'Irradiance (W/sr/m^2)', 'FontSize', 16)
            title(faxes5, 'Comparing Wavelength of Light to Its Irradiance', 'FontSize', 16)
            uistack(faxes5, 'top');
            faxes1.Visible = 'off';
            faxes3.Visible = 'off';
            faxes4.Visible = 'off';
            faxes2.Visible = 'off';
        end
    end
end
function folderButton_Callback(~,~)
    folder = uigetdir;
    if folder ~= 0
        folderSelect = true;
    end
end
end
