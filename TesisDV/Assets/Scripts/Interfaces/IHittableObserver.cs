using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IHittableObserver
{
    void OnNotify(string message);
}
