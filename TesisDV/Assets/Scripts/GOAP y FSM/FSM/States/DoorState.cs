using System;
using FSM;

public class DoorState : MonoBaseState
{
    public override void UpdateLoop()
    {
        
    }

     public override IState ProcessInput()
    {
       return this;
    }
}
