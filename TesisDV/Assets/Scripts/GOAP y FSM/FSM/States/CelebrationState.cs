using UnityEngine;
using System;
using FSM;
using UnityEngine.AI;

public class CelebrationState : MonoBaseState
{

    public override void UpdateLoop()
    {
        
    }

    
    public override IState ProcessInput()
    {
        return this;
    }
}
