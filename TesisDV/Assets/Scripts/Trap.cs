using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class Trap : MonoBehaviour
{
    public Switch trapSwitch;
    public bool active = false;

    public virtual void Activate() { }
}
