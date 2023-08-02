how the dataset will be organized:

dataset/
    ├── class1/
    │   ├── component1/
    │   │   ├── image1.jpg
    │   │   ├── image2.jpg
    │   │   ├── ...
    │   │   ├── image22.jpg
    │   │
    │   ├── component2/
    │   │   ├── image1.jpg
    │   │   ├── image2.jpg
    │   │   ├── ...
    │   │   ├── image22.jpg
    │   │
    │   ├── ...
    │
    └── class2/
        ├── component1/
        │   ├── image1.jpg
        │   ├── image2.jpg
        │   ├── ...
        │   ├── image22.jpg        
        │
        ├── component2/
        │   ├── image1.jpg
        │   ├── image2.jpg
        │   ├── ...
        │   ├── image22.jpg        
        │
        ├── ...

total data (images): 220
training data (80%): 176
testing data (20%): 44

folders that need cropping:
C:\Users\student\Documents\snhl-ERP\machine learning\training\N1\Healthy
C:\Users\student\Documents\snhl-ERP\machine learning\training\N1\Hearing Impaired
C:\Users\student\Documents\snhl-ERP\machine learning\training\N2\Healthy
C:\Users\student\Documents\snhl-ERP\machine learning\training\N2\Hearing Impaired
C:\Users\student\Documents\snhl-ERP\machine learning\training\P1\Healthy
C:\Users\student\Documents\snhl-ERP\machine learning\training\P1\Hearing Impaired
C:\Users\student\Documents\snhl-ERP\machine learning\training\P2\Healthy
C:\Users\student\Documents\snhl-ERP\machine learning\training\P2\Hearing Impaired
C:\Users\student\Documents\snhl-ERP\machine learning\training\P3\Healthy
C:\Users\student\Documents\snhl-ERP\machine learning\training\P3\Hearing Impaired

C:\Users\student\Documents\snhl-ERP\machine learning\testing\N1\Healthy
C:\Users\student\Documents\snhl-ERP\machine learning\testing\N1\Hearing Impaired
C:\Users\student\Documents\snhl-ERP\machine learning\testing\N2\Healthy
C:\Users\student\Documents\snhl-ERP\machine learning\testing\N2\Hearing Impaired
C:\Users\student\Documents\snhl-ERP\machine learning\testing\P1\Healthy
C:\Users\student\Documents\snhl-ERP\machine learning\testing\P1\Hearing Impaired
C:\Users\student\Documents\snhl-ERP\machine learning\testing\P2\Healthy
C:\Users\student\Documents\snhl-ERP\machine learning\testing\P2\Hearing Impaired
C:\Users\student\Documents\snhl-ERP\machine learning\testing\P3\Healthy
C:\Users\student\Documents\snhl-ERP\machine learning\testing\P3\Hearing Impaired



original_dataset_path = 'C:\\Users\\student\\Documents\\snhl-ERP\\machine learning\\dataset'
new_dataset_path = 'C:\\Users\\student\\Documents\\snhl-ERP\\machine learning\\new dataset'
