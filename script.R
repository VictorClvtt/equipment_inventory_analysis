################################
# EQUIPMENT INVENTORY ANALYSIS #
################################

#######################
# IMPORTING LIBRARIES #
#######################

library(dplyr)
library(ggplot2)


##################
# IMPORTING DATA #
##################

df <- read.csv(file = 'data/Montgomery_Fleet_Equipment_Inventory_FA_PART_1_START.csv')


###################
# CHECKING ERRORS #
###################

# Checking for rows that are completely filled with NA or empty strings
df %>% apply(1, function(x) all(is.na(x) | x == ""))

# Checking for misspellings in the 'Department' and 'Department.Class' column
df$Department %>% unique()
df$Equipment.Class %>% unique()


############################
# FIXING IDENTIFIED ERRORS #
############################

# Filtering empty rows out
df <- df[!df %>% apply(1, function(x) all(is.na(x) | x == "")), ]


################################################################
# TURNING 'Department' AND 'Department.1' INTO A SINGLE COLUMN #
################################################################

df$Department <- paste(df$Department, df$Department.1)

# Removing possible white spaces
df$Department <- df$Department %>% trimws()

# Removing the Department.1 column
df <- df %>% select(-Department.1)


############################
# FIXING SPELLING MISTAKES #
############################

# Fixing spelling mistakes in the 'Department' column
df$Department[df$Department == 'Correction and Rehabilltation'] <- 'Correction and Rehabilitation'
df$Department[df$Department == 'Fire and Recsue'] <- 'Fire and Rescue'
df$Department[df$Department == 'General Servcies'] <- 'General Services'
df$Department[df$Department == 'Health and Human Servcies'] <- 'Health and Human Services'

# Fixing spelling mistakes in the 'Department.Class' column
df$Equipment.Class[df$Equipment.Class == 'Off Road VehicleEquipment'] <- 'Off Road Vehicle Equipment'
df$Equipment.Class[df$Equipment.Class == 'Public  Safety Sedan'] <- 'Public Safety Sedan'
df$Equipment.Class[df$Equipment.Class == 'Public  Safety SUV'] <- 'Public Safety SUV'
df$Equipment.Class[df$Equipment.Class == 'Pick Up  Trucks'] <- 'Pick Up Trucks'


##################################################
# AGGREGATING DATA IN ORDER TO ANALYZE IT BETTER #
##################################################

viz_1 <- df %>% group_by(Department) %>% summarise(Total_Equipment = sum(Equipment.Count, na.rm = TRUE)) %>% arrange(Total_Equipment)

viz_2 <- df %>% group_by(Department, Equipment.Class) %>% summarise(Total_Equipment = sum(Equipment.Count, na.rm = TRUE)) %>% arrange(Total_Equipment)

viz_3 <- df %>% group_by(Equipment.Class, Department) %>% summarise(Total_Equipment = sum(Equipment.Count, na.rm = TRUE)) %>% arrange(Total_Equipment)


####################################################
# CREATING VISUALIZATIONS FROM THE AGGREGATED DATA #
####################################################

# Graph for viz_1
ggplot(viz_1, aes(x = reorder(Department, Total_Equipment), y = Total_Equipment)) +
  geom_col(fill = "steelblue") +
  geom_text(aes(label = Total_Equipment), 
            vjust = -0.25,
            size = 3.5) +
  labs(title = "Total de Equipamentos por Departamento",
       x = "Departamento",
       y = "Total de Equipamentos") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 0.9),
        panel.grid.major.x = element_blank(),  # remove grid vertical
        panel.grid.minor.x = element_blank(),  # remove grid vertical
        panel.grid.major.y = element_line(color = "gray80", size = 0.5)  # keep horizontal grid
       )

ggsave("graphs/viz_1.png", bg = 'white', width = 10, height = 6, dpi = 300)

# Graph for viz_2
ggplot(viz_2, aes(x = reorder(Department, Total_Equipment), y = Total_Equipment, fill = Equipment.Class)) +
  geom_col() +
  
  labs(title = "Equipamentos por Departamento e Classe",
       x = "Departamento",
       y = "Total de Equipamentos",
       fill = "Classe de Equipamento") +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 0.9),
    panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_line(color = "gray80")
  )

ggsave("graphs/viz_2.png", bg = 'white', width = 10, height = 6, dpi = 300)

# Graph for viz_3
ggplot(viz_3, aes(x = reorder(Equipment.Class, Total_Equipment), y = Total_Equipment, fill = Department)) +
  geom_col() +
  labs(title = "Equipamentos por Classe e Departamento",
       x = "Classe de Equipamento",
       y = "Total de Equipamentos",
       fill = "Departamento") +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 0.9),
    panel.grid.major.x = element_line(color = "gray80"),
    panel.grid.major.y = element_blank()
  )

ggsave("graphs/viz_3.png", bg = 'white', width = 15, height = 10, dpi = 300)

