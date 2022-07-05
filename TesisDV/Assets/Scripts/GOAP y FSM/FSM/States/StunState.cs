using System;
using FSM;

public class StunState : MonoBaseState
{
    public override void UpdateLoop()
    {
        
    }

     public override IState ProcessInput()
    {
       return this;
    }
}
