vortex = []
source = []
sink = []
cons = []
a = 1
while ( a != 0):
    print("Tipo de vento:")
    print("0 - Done")
    print("1 - constante")
    print("2 - vortex")
    print("3 - sink")
    print("4 - source")

    a = int(input("Inserir numero "))
    if (a != 0):
        x = float(input("Inserir a Posicao X: "))
        y = float(input("Inserir a Posicao Y: "))
        z = float(input("Inserir a Posicao Z: "))
        intensidade = float(input("Intensidade do vento: "))
        
        position = [x,y,z,intensidade]
        
        if (a == 1):
            cons.append(position);
        if (a == 2):
            vortex.append(position);
        if (a == 3):
            sink.append(position);
        if (a == 4):
            source.append(position);

array = np.zeros([100, 4, 4], dtype=np.uint8)

#vortex = [ [125,125,125,125], [50,50,50,50], ]
#source = [ [50,200,200,200],  [200,200,200,200]]
#sink   = [ [200,50,50,50] ]
#cons   = [ [160,160,160,160] ]

if cons:
    for i in enumerate(cons):
        print(i)
        array[ i[0] , 0] = cons[i[0]]
if vortex:    
    for i in enumerate(vortex):
        print(i)
        array[ i[0] , 1] = vortex[i[0]]
if sink:
    for i in enumerate(sink):
        print(i)
        array[ i[0] , 2] = sink[i[0]]
if source:
    for i in enumerate(source):
        print(i)
        array[ i[0] , 3] = source[i[0]]

img = Image.fromarray(array)
img.save('wind.png')