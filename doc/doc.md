# Double pendule

![Formule du double pendule](image.png)

## Notations

- $L_1, L_2$ : longueurs des bars
- $m_1, m_2$ : masses  
- $\theta_1, \theta_2$ : angles 
- $\dot{\theta}_1, \dot{\theta}_2$ : vitesses angulaires  
- $\ddot{\theta}_1, \ddot{\theta}_2$ : accélérations angulaires  
- $g$ : gravité 
- $c_1, c_2$ : frottement 

## Positions

$$x_1 = L_1 \sin \theta_1$$
$$y_1 = -L_1 \cos \theta_1$$
$$x_2 = x_1 + L_2 \sin \theta_2$$
$$y_2 = y_1 - L_2 \cos \theta_2$$

## Vitesses

$$\dot{x}_1 = \dot{\theta}_1 L_1 \cos \theta_1$$
$$\dot{y}_1 = \dot{\theta}_1 L_1 \sin \theta_1$$
$$\dot{x}_2 = \dot{x}_1 + \dot{\theta}_2 L_2 \cos \theta_2$$
$$\dot{y}_2 = \dot{y}_1 + \dot{\theta}_2 L_2 \sin \theta_2$$

## Accélérations

$$\ddot{x}_1 = -\dot{\theta}_1^2 L_1 \sin \theta_1 + \ddot{\theta}_1 L_1 \cos \theta_1$$
$$\ddot{y}_1 = \dot{\theta}_1^2 L_1 \cos \theta_1 + \ddot{\theta}_1 L_1 \sin \theta_1$$
$$\ddot{x}_2 = \ddot{x}_1 - \dot{\theta}_2^2 L_2 \sin \theta_2 + \ddot{\theta}_2 L_2 \cos \theta_2$$
$$\ddot{y}_2 = \ddot{y}_1 + \dot{\theta}_2^2 L_2 \cos \theta_2 + \ddot{\theta}_2 L_2 \sin \theta_2$$

## Équations du mouvement

$$\Delta = \theta_1 - \theta_2$$

### Accélération angulaire du premier pendule

$$\ddot{\theta}_1 = \frac{-g(2m_1 + m_2)\sin\theta_1 - m_2 g \sin(\theta_1 - 2\theta_2) - 2 m_2 \sin\Delta\left(\dot{\theta}_2^2 L_2 + \dot{\theta}_1^2 L_1 \cos\Delta\right)}{L_1 \left( 2m_1 + m_2 - m_2 \cos(2\Delta) \right)}$$

### Accélération angulaire du second pendule

$$\ddot{\theta}_2 = \frac{2 \sin\Delta\left(\dot{\theta}_1^2 L_1 (m_1+m_2) + g(m_1+m_2)\cos\theta_1 + \dot{\theta}_2^2 L_2 m_2 \cos\Delta\right)}{L_2 \left( 2m_1 + m_2 - m_2 \cos(2\Delta)\right)}$$

## Frottement

$$\ddot{\theta}_1 \leftarrow \ddot{\theta}_1 - c_1 \dot{\theta}_1$$
$$\ddot{\theta}_2 \leftarrow \ddot{\theta}_2 - c_2 \dot{\theta}_2$$



source : https://www.myphysicslab.com/pendulum/double-pendulum-en.html
