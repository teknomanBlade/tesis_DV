using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ArrowUIIndicator : MonoBehaviour
{
    void Awake()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        Vector3 rotacionActual = Vector3.zero;

        // Aplicar clamp en el eje X
        rotacionActual.x = Mathf.Clamp(rotacionActual.x, 0f, 0f);
        rotacionActual.y = Mathf.Clamp(rotacionActual.y, 0f, 0f);
        rotacionActual.z = GameVars.Values.Player.transform.eulerAngles.y;
        // Asignar la rotación ajustada
        transform.localEulerAngles = rotacionActual;
        transform.localRotation = Quaternion.Euler(transform.localEulerAngles);
    }
}
